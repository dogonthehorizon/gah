module Gah.Monad where

import Control.Lens           (camelCaseFields, makeLensesWith)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad.Reader   (MonadReader, ReaderT)
import Data.Text (Text)

data Context = Context {
    contextApiToken :: Text
  }

makeLensesWith camelCaseFields ''Context

-- | The Gah monad consisting of a reader context and IO.
newtype Gah a = Gah {
  runGah :: ReaderT Context IO a
} deriving (Applicative, Functor, Monad, MonadIO, MonadReader Context)
