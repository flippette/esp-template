//! common utilities for firmware.

#![no_std]
#![feature(decl_macro, macro_attr)]
#![expect(unstable_features)]

pub mod error;
pub mod macros;

pub mod prelude {
  pub use crate::error::{Error, FallibleExt};
  pub use crate::macros::{main, make_static};
}
