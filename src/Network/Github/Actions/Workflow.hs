module Network.Github.Actions.Workflow where

import Data.Aeson   (FromJSON)
import Data.Text    (Text)
import GHC.Generics (Generic)

data Workflow = Workflow {
    id   :: Int,
    name :: Text
    -- TODO do we need more fields?
    -- https://docs.github.com/en/rest/reference/actions#list-repository-workflows
  } deriving (Generic, Show)

instance FromJSON Workflow
