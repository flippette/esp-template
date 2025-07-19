//! error handling.

use embassy_executor::SpawnError;

crate::error! {
  /// common error type.
  #[derive(Clone)]
  pub enum Error {
    AdHoc(&'static str) => "ad-hoc error: {}",
    Spawn(SpawnError) => "task spawn error: {}",
  }
}

/// utils for [`Option`] and [`Result`].
#[allow(dead_code)]
pub trait FallibleExt<T>: Sized {
  fn or_adhoc(self, msg: &'static str) -> Result<T, Error>;
}

impl<T> FallibleExt<T> for Option<T> {
  fn or_adhoc(self, msg: &'static str) -> Result<T, Error> {
    self.ok_or(Error::AdHoc(msg))
  }
}

impl<T, E> FallibleExt<T> for Result<T, E> {
  fn or_adhoc(self, msg: &'static str) -> Result<T, Error> {
    self.or(Err(Error::AdHoc(msg)))
  }
}
