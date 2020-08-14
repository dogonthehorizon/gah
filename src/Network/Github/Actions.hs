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

getLatestLogsForPredicate :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
                   => Text
                   -> Text
                   -> (Run.Run -> Bool)
                   -> m (Either Text ())
getLatestLogsForPredicate org repo predicate = do
  workflowRuns <- Run.workflowRuns <$> Actions.runs org repo
  case find predicate workflowRuns of
    Nothing -> return . Left $ "no recent run"
    Just r ->
      Right <$> Actions.logs org repo (Run.id r)

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
    Just desiredFlowId ->
      getLatestLogsForPredicate org repo $ \r ->
        Run.workflowId r == desiredFlowId

-- TODO this method needs to be cleaned up.
getLatestLogsForBranch :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
                   => Text
                   -> Text
                   -> Text
                   -> m (Either Text ())
getLatestLogsForBranch branch org repo =
  getLatestLogsForPredicate org repo $ \r ->
    Run.headBranch r == branch


-- TODO this method needs to be cleaned up.
getLatestLogsForWorkflowAndBranch :: (MonadReader ctx m, HasApiToken ctx Text, MonadHttp m)
                   => Text
                   -> Text
                   -> Text
                   -> Text
                   -> m (Either Text ())
getLatestLogsForWorkflowAndBranch workflow branch org repo = do
  flows <- Actions.workflows org repo
  case M.lookup workflow flows of
    Nothing -> return . Left $ "workflow not found" -- TODO better error message
    Just desiredFlowId ->
      getLatestLogsForPredicate org repo $ \r ->
        Run.workflowId r == desiredFlowId && Run.headBranch r == branch
