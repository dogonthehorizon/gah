{-# LANGUAGE DuplicateRecordFields #-}

module Network.Github.Api where

import TextShow (showt)
import Data.Aeson (FromJSON(..), genericParseJSON, defaultOptions, fieldLabelModifier)
import Data.Aeson.Casing (snakeCase)
import GHC.Generics (Generic)
import           Codec.Archive.Zip.Conduit.UnZip (unZipStream)
import           Codec.Archive.Zip.Conduit.Zip   (ZipEntry)
import           Conduit                         (mapC, stdoutC)
import           Control.Lens                    (view)
import           Control.Monad                   (void)
import           Control.Monad.IO.Class          (MonadIO)
import           Control.Monad.Reader            (MonadReader, ask)
import           Data.ByteString                 (ByteString)
import           Data.Conduit                    (runConduitRes, (.|))
import           Data.Text                       (Text)
import qualified Data.Text.Encoding              as T
import           Gah.Monad
import           Network.HTTP.Req                (GET (..), NoReqBody (..),
                                                  Option, defaultHttpConfig,
                                                  header, https, oAuth2Token,
                                                  reqBr, runReq, (/:), req, jsonResponse, responseBody)
import           Network.HTTP.Req.Conduit

-- TODO support honoring rate limits

github :: Text
github = "api.github.com"

-- TODO pull in actual version used for the UA string.
userAgent :: Option https
userAgent = header "User-Agent" "gah/0.0.1"

accept :: Option https
accept = header "Accept" "application/vnd.github.v3+json"

data Workflow = Workflow {
    id :: Int,
    name :: Text
    -- TODO do we need more fields?
    -- https://docs.github.com/en/rest/reference/actions#list-repository-workflows
  } deriving (Generic, Show)

instance FromJSON Workflow

workflow :: (MonadReader ctx m, HasApiToken ctx Text, MonadIO m) => Int -> m Workflow
workflow wId = do
  token <- view apiToken <$> ask
  runReq defaultHttpConfig $ do
    let url = https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "workflows" /: showt wId
    let headers = userAgent <> accept <> oAuth2Token (T.encodeUtf8 token)
    responseBody <$> req GET url NoReqBody jsonResponse headers

data Run = Run {
    id :: Int,
    headBranch :: Text,
    event :: Text,
    status :: Text,
    workflowId :: Int,
    url :: Text
  } deriving (Generic, Show)

instance FromJSON Run where
   parseJSON = genericParseJSON options 
    where options = defaultOptions { fieldLabelModifier = snakeCase }


data RunResult = RunResult {
    totalCount :: Int,
    workflowRuns :: [Run]
  } deriving (Generic, Show)

instance FromJSON RunResult where
   parseJSON = genericParseJSON options 
    where options = defaultOptions { fieldLabelModifier = snakeCase }

runs :: (MonadReader ctx m, HasApiToken ctx Text, MonadIO m) => m RunResult
runs = do
  token <- view apiToken <$> ask
  runReq defaultHttpConfig $ do
    let url = https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "runs"
    let headers = userAgent <> accept <> oAuth2Token (T.encodeUtf8 token)
    responseBody <$> req GET url NoReqBody jsonResponse headers

-- TODO consider inlining into logs fn
extractLogs :: Either ZipEntry ByteString -> ByteString
extractLogs (Left _)  = ""
extractLogs (Right x) = x

-- TODO embed req in Gah monad via MonadHttp
logs :: (MonadReader ctx m, HasApiToken ctx Text, MonadIO m) => m ()
logs = do
  token <- view apiToken <$> ask
  runReq defaultHttpConfig $ do
    let url = https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "runs" /: "186342587" /: "logs"
    let headers = userAgent <> accept <> oAuth2Token (T.encodeUtf8 token)
    reqBr GET url NoReqBody headers $ \r ->
      runConduitRes $
        responseBodySource r .| void unZipStream .| mapC extractLogs .| stdoutC
