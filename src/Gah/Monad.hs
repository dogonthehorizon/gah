module Gah.Monad where

import Control.Exception      (throwIO)
import Control.Lens           (camelCaseFields, makeLensesWith)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Reader   (MonadReader, ReaderT)
import Data.Text              (Text)
import Network.HTTP.Req       (MonadHttp (handleHttpException))

data Context = Context {
    contextApiToken :: Text
  }

makeLensesWith camelCaseFields ''Context

-- | The Gah monad consisting of a reader context and IO.
newtype Gah a = Gah {
  runGah :: ReaderT Context IO a
} deriving (Applicative, Functor, Monad, MonadIO, MonadReader Context)

instance MonadHttp Gah where
  handleHttpException = liftIO . throwIO
