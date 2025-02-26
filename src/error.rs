//! Error handling facilities.

use defmt::Str;
use embassy_executor::SpawnError;

crate::error_def! {
    AdHoc => Str = "ad-hoc error: {}",
    Spawn => SpawnError = "task spawn failed: {}",
}
