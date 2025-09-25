//! error handling.

use defmt::{Format, Str, unwrap};

crate::macros::error! {
  /// common error type.
  pub enum Error {
    AdHoc(Str) => "ad-hoc error: {}",
  }
}

/// make a [`Result`] with an [`Error::AdHoc`].
pub trait ToAdHocError<T> {
  fn or_adhoc(self, msg: Str) -> Result<T, Error>
  where
    Self: Sized;
}

/// trait-level `unwrap()`, using [`defmt`].
pub trait Force<T>: Sized {
  fn force(self) -> T;
}

impl<T> ToAdHocError<T> for Option<T> {
  fn or_adhoc(self, msg: Str) -> Result<T, Error>
  where
    Self: Sized,
  {
    self.ok_or(msg.into())
  }
}

impl<T, E> ToAdHocError<T> for Result<T, E> {
  fn or_adhoc(self, msg: Str) -> Result<T, Error>
  where
    Self: Sized,
  {
    self.map_err(|_| msg.into())
  }
}

impl<T> Force<T> for Option<T> {
  fn force(self) -> T {
    unwrap!(self)
  }
}

impl<T, E> Force<T> for Result<T, E>
where
  E: Format,
{
  fn force(self) -> T {
    unwrap!(self)
  }
}

// `() -> ()` trivially
impl Force<()> for () {
  fn force(self) {}
}

// `! -> ()` trivially
impl Force<()> for ! {
  fn force(self) {}
}
