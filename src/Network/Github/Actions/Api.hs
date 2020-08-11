{-# LANGUAGE DataKinds #-}

module Network.Github.Actions.Api where

import           Codec.Archive.Zip.Conduit.UnZip (unZipStream)
import           Codec.Archive.Zip.Conduit.Zip   (ZipEntry)
import           Conduit                         (mapC, stdoutC)
import           Control.Lens                    (view)
import           Control.Monad                   (void)
import           Control.Monad.Reader            (MonadReader, asks)
import           Data.ByteString                 (ByteString)
import           Data.Conduit                    (runConduitRes, (.|))
import           Data.HashMap.Strict             (HashMap, fromList)
import           Data.Text                       (Text)
import qualified Data.Text.Encoding              as T
import           Gah.Monad
import           Network.Github.Actions.Run      (RunResult)
import qualified Network.Github.Actions.Run      as Run
import qualified Network.Github.Actions.Workflow as Workflow
import           Network.HTTP.Req                (GET (..), MonadHttp,
                                                  NoReqBody (..), Option,
                                                  Scheme (Https), header, https,
                                                  jsonResponse, oAuth2Token,
                                                  req, reqBr, responseBody,
                                                  (/:))
import           Network.HTTP.Req.Conduit
import           TextShow                        (showt)
import qualified Paths_gah                 as Paths
import Data.Version (showVersion)
import qualified Data.ByteString.Char8 as B

-- TODO consider splitting "Github" monad from "Gah" monad, or renaming.
-- TODO support honoring rate limits

-- | Url for github.
github :: Text
github = "api.github.com"

-- | User agent to report to the Github api.
userAgent :: Option https
userAgent = header "User-Agent" $ "gah/" <> (B.pack $ showVersion Paths.version)

-- | Default accept header for all Github requests.
accept :: Option https
accept = header "Accept" "application/vnd.github.v3+json"

-- | The default set of headers used for all requests.
-- TODO move into Internal module
headers :: Text -> Option 'Https
headers token = userAgent <> accept <> oAuth2Token (T.encodeUtf8 token)

-- | Get all workflows for the given org/repo.
workflows :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
          => Text
          -> Text
          -> m (HashMap Text Int)
workflows org repo = do
  token <- asks (view apiToken)
  let url = https github /: "repos" /: org /: repo /: "actions" /: "workflows"
  response <- responseBody <$> req GET url NoReqBody jsonResponse (headers token)
  return . fromList
    $ (\w -> (Workflow.name w, Workflow.id w))
    <$> Workflow.workflows response


-- | Get all runs for the given org/repo.
runs :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
     => Text
     -> Text
     -> m RunResult
runs org repo = do
  token <- asks (view apiToken)
  let url = https github /: "repos" /: org /: repo /: "actions" /: "runs"
  responseBody <$> req GET url NoReqBody jsonResponse (headers token)

-- | Retrieve logs for the given org/repo/runId and send them to STDOUT.
--
-- Logs themselves are sent back to the client as a Zip archive, so we use
-- conduit here to stream in constant space and unpack to STDOUT.
logs :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
     => Text
     -> Text
     -> Int
     -> m ()
logs org repo runId = do
  token <- asks (view apiToken)
  let url = https github /: "repos" /: org /: repo /: "actions" /: "runs" /: showt runId /: "logs"
  reqBr GET url NoReqBody (headers token) $ \r ->
    runConduitRes $
      responseBodySource r .| void unZipStream .| mapC extractLogs .| stdoutC
        where  extractLogs :: Either ZipEntry ByteString -> ByteString
               -- Ignore left values because they only represent files names.
               extractLogs (Left _)  = ""
               -- Pass through Right values because that's the content of the archive.
               extractLogs (Right x) = x
