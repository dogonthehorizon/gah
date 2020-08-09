module Main where

import           Config                     (GahConfig (..), getConfig)
--import Control.Monad.IO.Class (liftIO)
import           Control.Monad.Reader       (runReaderT)
import           Gah.Monad
import qualified Network.Github.Actions.Api as Actions
import qualified Network.Github.Actions.Run as Run

-- TODO build CLI parser
org = "armory"
repo = "dinghy"

main :: IO ()
main = do
  token <- gahApiToken <$> getConfig
  flip runReaderT (Context token) $ runGah $ do
    rId <- Run.id . head . Run.workflowRuns <$> Actions.runs org repo
    Actions.logs org repo rId
