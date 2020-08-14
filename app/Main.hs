module Main where

import           Cli                    (Action (..), parseCliOpts, withInfo)
import qualified Cli                    as CliOpts
import           Config                 (GahConfig (..), getConfig)
import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Reader   (runReaderT)
import           Data.Text              (Text)
import           Gah.Monad
import qualified Network.Github.Actions as Actions
import           Options.Applicative    (execParser)

main :: IO ()
main = execParser (parseCliOpts `withInfo` "") >>= \opts ->
  case CliOpts.action opts of
    -- TODO consider moving to some other method
    GetLogs -> do
      token <- gahApiToken <$> getConfig
      let org = CliOpts.org opts
      let repo = CliOpts.repo opts
      let actionFn = case (CliOpts.workflow opts, CliOpts.branch opts) of
                       (Nothing, Nothing)  -> Actions.getLatestRunLogs
                       (Just wId, Nothing) -> Actions.getLatestLogsForWorkflow wId
                       (Nothing, Just b) -> Actions.getLatestLogsForBranch b
                       (Just wId, Just b) -> Actions.getLatestLogsForWorkflowAndBranch wId b

      flip runReaderT (Context token) $ runGah $ do
        logAction <- actionFn org repo
        case logAction of
          Left e  -> liftIO . print $ (e :: Text) -- TODO better error handling
          Right _ -> return ()
