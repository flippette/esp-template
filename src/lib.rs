//! common utilities for firmware.

#![no_std]
#![feature(decl_macro, macro_attr, never_type)]
#![expect(unstable_features)]

pub mod error;
pub mod macros;

pub mod prelude {
  pub use crate::error::{Error, Force, ToAdHocError};
  pub use crate::macros::{main, make_static};
}
