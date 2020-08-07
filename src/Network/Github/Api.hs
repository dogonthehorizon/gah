module Network.Github.Api where

-- TODO clean up imports
import           Codec.Archive.Zip.Conduit.UnZip (unZipStream)
import           Conduit                         (filterC)
import           Control.Lens                    ((^.))
import           Control.Monad.IO.Class          (MonadIO, liftIO)
import           Control.Monad.Reader            (MonadReader, ask)
import           Data.Conduit                    (runConduitRes, (.|))
import qualified Data.Conduit.Binary             as CB
import           Data.Text                       (Text)
import qualified Data.Text.Encoding              as T
import           Gah.Monad
import           Network.HTTP.Req                (GET (..), NoReqBody (..),
                                                  Option, bsResponse,
                                                  defaultHttpConfig, header,
                                                  https, oAuth2Token, req,
                                                  reqBr, responseBody, runReq,
                                                  (/:))
import           Network.HTTP.Req.Conduit

-- TODO support honoring rate limits

github :: Text
github = "api.github.com"

-- TODO pull in actual version used for the UA string.
userAgent :: Option https
userAgent = header "User-Agent" "gah/0.0.1"

accept :: Option https
accept = header "Accept" "application/vnd.github.v3+json"

-- TODO embed req in Gah monad via MonadHttp
logs :: (MonadReader ctx m, HasApiToken ctx Text, MonadIO m) => m ()
logs = do
  ctx <- ask
  let token = ctx ^. apiToken
  runReq defaultHttpConfig $ do
    let url = https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "runs" /: "186342587" /: "logs"
    let headers = userAgent <> accept <> oAuth2Token (T.encodeUtf8 token)
    reqBr GET url NoReqBody headers $ \r ->
      runConduitRes $
        responseBodySource r .| unZipStream .| CB.sinkFile "my-file.bin"
