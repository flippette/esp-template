//! Error handling facilities.

use crate::make_static;
use core::str;
use defmt::{Format, Str, write};
use embassy_executor::SpawnError;
use heapless::Vec;

crate::error_def! {
    AdHoc => Str = "ad-hoc error: {}",
    Spawn => SpawnError = "task spawn failed: {}",
}

/// An error type carrying a backtrace.
pub struct Report<const N: usize> {
    pub error: Error,
    pub backtrace: Vec<Location, N>,
    pub more: bool,
}

/// Alternative of [`core::panic::Location`].
pub struct Location {
    pub file: &'static str,
    pub line: u32,
    pub column: u32,
}

/// Convenience trait for converting into [`Result<T, Report<N>>`].
#[allow(dead_code)]
pub trait ResultExt<T, const N: usize> {
    #[track_caller]
    fn into_report(self) -> Result<T, Report<N>>;
}

impl Location {
    /// Get the file location of the last unannotated function in the call
    /// stack.
    #[track_caller]
    pub fn caller() -> Self {
        core::panic::Location::caller().into()
    }
}

impl Format for Location {
    fn format(&self, fmt: defmt::Formatter) {
        write!(
            fmt,
            "{=str}:{=u32}:{=u32}",
            self.file, self.line, self.column
        )
    }
}

impl From<&core::panic::Location<'_>> for Location {
    fn from(loc: &core::panic::Location<'_>) -> Self {
        let file_buf = make_static!(const [u8; 32] = [0; _]);
        file_buf.copy_from_slice(loc.file().as_bytes());

        Self {
            file: unsafe {
                str::from_utf8_unchecked(&file_buf[..loc.file().len()])
            },
            line: loc.line(),
            column: loc.column(),
        }
    }
}

impl<T, E, const N: usize> ResultExt<T, N> for Result<T, E>
where
    E: Into<Error>,
{
    fn into_report(self) -> Result<T, Report<N>> {
        self.map_err(|err| {
            let mut backtrace = Vec::new();
            let mut more = false;
            if backtrace.insert(0, Location::caller()).is_err() {
                more = true;
            }

            Report {
                error: err.into(),
                backtrace,
                more,
            }
        })
    }
}

impl<T, const N: usize> ResultExt<T, N> for Result<T, Report<N>> {
    fn into_report(self) -> Result<T, Report<N>> {
        self.map_err(|mut rep| {
            if rep.backtrace.is_full() {
                rep.backtrace.pop();
                rep.more = true;
            }

            let _ = rep.backtrace.insert(0, Location::caller());
            rep
        })
    }
}
