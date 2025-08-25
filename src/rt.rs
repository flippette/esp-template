//! runtime setup.

#![allow(unreachable_code)]

use defmt::{info, unwrap};
use embassy_executor::Spawner;
use esp_hal_embassy::main;

// required by espflash
esp_bootloader_esp_idf::esp_app_desc!();

#[main]
async fn _start(s: Spawner) {
  unwrap!(crate::main(s).await);
  info!("main exited!");
}
