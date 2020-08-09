module Network.Github.Actions where

import           Control.Monad.Reader       (MonadReader)
import qualified Data.HashMap.Strict        as M
import           Data.List                  (find)
import           Data.Text                  (Text)
import           Gah.Monad
import qualified Network.Github.Actions.Api as Actions
import qualified Network.Github.Actions.Run as Run
import           Network.HTTP.Req           (MonadHttp)

getLatestRunLogs :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
                 => Text
                 -> Text
                 -> m (Either Text ())
getLatestRunLogs org repo = do
    rId <- Run.id . head . Run.workflowRuns <$> Actions.runs org repo
    Right <$> Actions.logs org repo rId

-- TODO this method needs to be cleaned up.
getLatestLogsForWorkflow :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
                   => Text
                   -> Text
                   -> Text
                   -> m (Either Text ())
getLatestLogsForWorkflow workflow org repo = do
  flows <- Actions.workflows org repo
  case M.lookup workflow flows of
    Nothing -> return . Left $ "workflow not found" -- TODO better error message
    Just desiredFlowId -> do
      workflowRuns <- Run.workflowRuns <$> Actions.runs org repo
      case find (\r -> Run.workflowId r == desiredFlowId) workflowRuns of
        Nothing -> return . Left $ "no recent run"
        Just r ->
          Right <$> Actions.logs org repo (Run.id r)
