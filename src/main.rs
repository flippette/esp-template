#![no_std]
#![no_main]
#![feature(macro_attr)]
#![expect(unstable_features)]

use defmt::info;
use embassy_executor::Spawner;
use esp_backtrace as _;
use esp_hal::timer::timg::TimerGroup;
use esp_println as _;
use esp_template::prelude::*;

// required for espflash
esp_bootloader_esp_idf::esp_app_desc!();

#[main]
async fn main(_s: Spawner) -> Result<(), Error> {
  let p = esp_hal::init(<_>::default());
  info!("hal init!");

  let timg = TimerGroup::new(p.TIMG0);
  esp_rtos::start(timg.timer0, p.FROM_CPU_INTR0);
  info!("rtos init!");

  Ok(())
}
