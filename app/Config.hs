module Config where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Text              (Text)
import GHC.Generics           (Generic)
import System.Envy            (FromEnv, decodeEnv)

data GahConfig = GahConfig {
  gahApiToken :: Text
} deriving (Generic, Show)

instance FromEnv GahConfig

getConfig :: (MonadIO m, MonadFail m) => m GahConfig
getConfig = do
  env <- liftIO (decodeEnv :: IO (Either String GahConfig))
  either fail return env
