//! runtime setup.

use defmt::{info, unwrap};
use embassy_executor::Spawner;
use esp_hal_embassy::main;

#[main]
async fn _start(s: Spawner) {
  unwrap!(crate::main(s).await);
  info!("main exited!");
}
