module Main where

import Control.Monad.Reader (runReaderT)
import Network.Github.Api (logs) 
import Config (getConfig, GahConfig(..))
import Gah.Monad


main :: IO ()
main = do
  token <- gahApiToken <$> getConfig
  flip runReaderT (Context token) $ logs
