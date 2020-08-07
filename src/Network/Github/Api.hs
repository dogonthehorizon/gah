module Network.Github.Api where

-- TODO clean up imports
import           Control.Monad.Reader   (MonadReader, ask)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Text (Text)
import Network.HTTP.Req (runReq, NoReqBody(..), defaultHttpConfig, req, GET(..), responseBody, bsResponse, (/:), https, header, Option, oAuth2Token, reqBr)
import qualified Data.Text.Encoding as T
import qualified Data.ByteString.Char8 as B
import Gah.Monad
import Control.Lens ((^.))
import Network.HTTP.Req.Conduit
import qualified Data.Conduit.Binary as CB
import Data.Conduit ((.|), runConduitRes)
import Conduit (filterC)
import Codec.Archive.Zip.Conduit.UnZip (unZipStream)

-- TODO support honoring rate limits

github :: Text
github = "api.github.com"

-- TODO pull in actual version used for the UA string.
userAgent :: Option https
userAgent = header "User-Agent" "gah/0.0.1"

accept :: Option https
accept = header "Accept" "application/vnd.github.v3+json"

noEntries (Left _) = false
noEntries (Right _) = true

-- TODO embed req in Gah monad via MonadHttp
logs :: (MonadReader ctx m, HasApiToken ctx Text, MonadIO m) => m ()
logs = do
  ctx <- ask
  let token = (ctx ^. apiToken)
  runReq defaultHttpConfig $ do
    let url = https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "runs" /: "186342587" /: "logs"
    let headers = userAgent <> accept <> (oAuth2Token (T.encodeUtf8 token))
    reqBr GET url NoReqBody headers $ \r ->
      runConduitRes $
        responseBodySource r .| unZipStream .| filterC noEntries .| CB.sinkFile "my-file.bin"
