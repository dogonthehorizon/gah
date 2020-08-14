module Cli where

import           Data.Text                 (Text)
import qualified Data.Text                 as T
import           Data.Version              (showVersion)
import           Options.Applicative
import           Options.Applicative.Types (readerAsk)
import qualified Paths_gah                 as Paths

data Action = GetLogs deriving (Show)

data CliOpts = CliOpts {
    action   :: Action,
    org      :: Text,
    repo     :: Text,
    workflow :: Maybe Text,
    branch   :: Maybe Text
  }

gahVersion :: String
gahVersion = "gah " <> showVersion Paths.version

-- | Parse an argument as 'Text'.
text :: ReadM Text
text = T.pack <$> readerAsk

parseOrg :: Parser Text
parseOrg = option text $
  short 'o'
  <> long "organization"
  <> help "The organization where your repository lives."

parseRepo :: Parser Text
parseRepo = option text $
  short 'r'
  <> long "repository"
  <> help "The repository to find Actions for."

parseWorkflow :: Parser Text
parseWorkflow = option text $
  short 'w'
  <> long "workflow"
  <> metavar "WORKFLOW_NAME"
  <> help "The name of the workflow to inspect."

parseBranch :: Parser Text
parseBranch = option text $
  short 'b'
  <> long "branch"
  <> metavar "BRANCH_NAME"
  <> help "The name of the branch to inspect."

parseLogs :: Parser Action
parseLogs = pure GetLogs

parseAction :: Parser Action
parseAction = subparser $
  command "logs" (parseLogs `withInfo` "Retrieve logs for the given org/repo and optional workflow.")

parseCliOpts :: Parser CliOpts
parseCliOpts = CliOpts
  <$> parseAction
  <*> parseOrg
  <*> parseRepo
  <*> optional parseWorkflow
  <*> optional parseBranch

-- | Parse a version flag.
parseVersion :: Parser (a -> a)
parseVersion = infoOption gahVersion $
  long "version"
  <> help "Print the current version and exit."

withInfo :: Parser a -> Text -> ParserInfo a
withInfo parser help = info (helper <*> parseVersion <*> parser)
  (fullDesc
  <> progDesc (T.unpack help)
  <> header (gahVersion <> " - GitHub Actions CLI for the flumoxed developer.")
  <> footer "Copyright (c) Fernando Freire 2020")
