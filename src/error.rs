//! error handling.

use defmt::Str;
use embassy_executor::SpawnError;
#[cfg(feature = "radio")]
use esp_radio::InitializationError as RadioInitError;
#[cfg(feature = "wifi")]
use esp_radio::wifi::{InternalWifiError, WifiError};

crate::macros::error! {
  /// common error type.
  pub enum Error {
    AdHoc(Str)                      => "ad-hoc error: {}",
    Spawn(SpawnError)               => "task spawn error: {}",

    #[cfg(feature = "radio")]
    RadioInit(RadioInitError)       => "radio init error: {}",

    #[cfg(feature = "wifi")]
    Wifi(WifiError)                 => "wi-fi error: {}",
    #[cfg(feature = "wifi")]
    WifiInternal(InternalWifiError) => "wi-fi internal error: {}",
  }
}

/// utils for [`Option`] and [`Result`].
#[allow(dead_code)]
pub trait FallibleExt<T>: Sized {
  fn or_adhoc(self, msg: Str) -> Result<T, Error>;
}

impl<T> FallibleExt<T> for Option<T> {
  fn or_adhoc(self, msg: Str) -> Result<T, Error> {
    self.ok_or(Error::AdHoc(msg))
  }
}

impl<T, E> FallibleExt<T> for Result<T, E> {
  fn or_adhoc(self, msg: Str) -> Result<T, Error> {
    self.or(Err(Error::AdHoc(msg)))
  }
}
