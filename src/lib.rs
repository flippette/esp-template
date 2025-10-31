//! common utilities for firmware.

#![no_std]
#![feature(macro_attr, never_type)]
#![expect(unstable_features)]

pub mod error;

mod macros;

pub mod prelude {
  pub use crate::error::{Error, Force, ToAdHocError};
  pub use crate::{error, main, make_static};
}
