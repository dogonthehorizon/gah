module Network.Github.Actions.Run where

import Data.Aeson        (FromJSON (..), defaultOptions, fieldLabelModifier,
                          genericParseJSON)
import Data.Aeson.Casing (snakeCase)
import Data.Text         (Text)
import GHC.Generics      (Generic)

-- | Represents a single workflow run.
data Run = Run {
    id         :: Int,
    headBranch :: Text,
    event      :: Text,
    status     :: Text,
    workflowId :: Int,
    url        :: Text
  } deriving (Generic, Show)

instance FromJSON Run where
   parseJSON = genericParseJSON options
    where options = defaultOptions { fieldLabelModifier = snakeCase }

-- | Represents all runs for a given org/repo pair.
data RunResult = RunResult {
    totalCount   :: Int,
    workflowRuns :: [Run]
  } deriving (Generic, Show)

instance FromJSON RunResult where
   parseJSON = genericParseJSON options
    where options = defaultOptions { fieldLabelModifier = snakeCase }
