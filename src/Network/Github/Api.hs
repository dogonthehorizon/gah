module Network.Github.Api where

-- TODO clean up imports
import           Control.Monad.Reader   (MonadReader, ask)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Text (Text)
import Network.HTTP.Req (runReq, NoReqBody(..), defaultHttpConfig, req, GET(..), responseBody, bsResponse, (/:), https, header, Option, oAuth2Token)
import qualified Data.Text.Encoding as T
import qualified Data.ByteString.Char8 as B
import Gah.Monad
import Control.Lens ((^.))

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
  let token = (ctx ^. apiToken)
  runReq defaultHttpConfig $ do
    bs <- req GET (https github /: "repos" /: "armory-io" /: "dinghy" /: "actions" /: "runs" /: "186342587" /: "logs") NoReqBody bsResponse (userAgent <> accept <> (oAuth2Token (T.encodeUtf8 token)))
    -- TODO this currently returns a zip archived file, need to use mkkarpov/zip to fiddle with
    --      potentially via https://hackage.haskell.org/package/req-conduit-1.0.0/docs/Network-HTTP-Req-Conduit.html
    liftIO . B.putStrLn $ responseBody bs
