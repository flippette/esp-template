#![no_std]
#![no_main]
#![feature(macro_attr)]
#![expect(unstable_features)]

use defmt::info;
use embassy_executor::Spawner;
use esp_hal::timer::systimer::SystemTimer;
use esp_template::prelude::*;
use {esp_backtrace as _, esp_println as _};

// required for espflash
esp_bootloader_esp_idf::esp_app_desc!();

#[main]
async fn main(_s: Spawner) -> Result<(), Error> {
  let p = esp_hal::init(<_>::default());
  let syst = SystemTimer::new(p.SYSTIMER);
  esp_hal_embassy::init(syst.alarm0);
  info!("hal init!");

  Ok(())
}
