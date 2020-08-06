module Config where

-- TODO clean up imports
import Control.Monad.IO.Class (MonadIO, liftIO)
import System.Envy
import GHC.Generics (Generic)
import qualified Data.Text as T
import Data.Text (Text)

data GahConfig = GahConfig {
  gahApiToken :: Text
} deriving (Generic, Show)

instance FromEnv GahConfig

getConfig :: (MonadIO m, MonadFail m) => m GahConfig
getConfig = do
  env <- liftIO $ (decodeEnv :: IO (Either String GahConfig))
  either fail (return . id) $ env
