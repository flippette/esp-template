#![no_std]
#![no_main]
#![feature(impl_trait_in_assoc_type)]
#![expect(unstable_features)]

mod error;
#[doc(hidden)]
mod macros;
mod rt;

use defmt::info;
use embassy_executor::Spawner;
use esp_hal::timer::systimer::SystemTimer;
use {esp_backtrace as _, esp_println as _};

use crate::error::Error;

async fn main(_s: Spawner) -> Result<(), Error> {
  let p = esp_hal::init(<_>::default());
  let syst = SystemTimer::new(p.SYSTIMER);
  esp_hal_embassy::init(syst.alarm0);
  info!("hal init!");

  Ok(())
}
