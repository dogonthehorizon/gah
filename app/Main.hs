module Main where

import Config               (GahConfig (..), getConfig)
import Control.Monad.Reader (runReaderT)
import Gah.Monad
import Network.Github.Api   (logs)


main :: IO ()
main = do
  token <- gahApiToken <$> getConfig
  runReaderT logs (Context token)
