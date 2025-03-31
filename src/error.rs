//! Error handling facilities.

use embassy_executor::SpawnError;

crate::error_def! {
    AdHoc => &'static str = "ad-hoc error: {}",
    Spawn => SpawnError = "task spawn error: {}",
}

/// Utilities for [`Option`] and [`Result`].
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
