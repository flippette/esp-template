//! error handling.

use defmt::Str;
use embassy_executor::SpawnError;
#[cfg(feature = "mbedtls")]
use esp_mbedtls::TlsError;
#[cfg(feature = "wifi")]
use esp_wifi::InitializationError as WifiInitError;
#[cfg(feature = "wifi")]
use esp_wifi::wifi::{InternalWifiError, WifiError};

crate::macros::error! {
  /// common error type.
  #[derive(Clone)]
  pub enum Error {
    AdHoc(Str)                      => "ad-hoc error: {}",
    Spawn(SpawnError)               => "task spawn error: {}",

    #[cfg(feature = "wifi")]
    Wifi(WifiError)                 => "wi-fi error: {}",
    #[cfg(feature = "wifi")]
    WifiInit(WifiInitError)         => "wi-fi init error: {}",
    #[cfg(feature = "wifi")]
    WifiInternal(InternalWifiError) => "wi-fi internal error: {}",

    #[cfg(feature = "mbedtls")]
    #[format(fun)]
    TlsError(TlsError)              => { error_format::format_tls_error },
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

/// error formatters.
#[allow(unused_imports)]
mod error_format {
  use defmt::{Formatter, write};

  use super::*;

  #[rustfmt::skip]
  #[cfg(feature = "mbedtls")]
  pub fn format_tls_error(fmt: Formatter, err: &TlsError) {
    match err {
      TlsError::AlreadyCreated            =>
        write!(fmt, "tls error: tls instance already created"),
      TlsError::Unknown                   =>
        write!(fmt, "tls error: unknown error"),
      TlsError::OutOfMemory               =>
        write!(fmt, "tls error: out of heap memory"),
      TlsError::MbedTlsError(code)        =>
        write!(fmt, "tls error: mbedtls error code {=u32:#04x}", code.unsigned_abs()),
      TlsError::Eof                       =>
        write!(fmt, "tls error: unexpected end of stream"),
      TlsError::X509MissingNullTerminator =>
        write!(fmt, "tls error: x509 pem certificate missing null terminator"),
      TlsError::NoClientCertificate       =>
        write!(fmt, "tls error: client didn't provide certificate"),
      TlsError::Io(kind)                  =>
        write!(fmt, "tls error: io error: {}", kind),
    }
  }
}
