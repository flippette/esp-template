#![no_std]
#![no_main]
#![feature(impl_trait_in_assoc_type, impl_trait_in_bindings)]
#![expect(unstable_features)]

mod error;
mod macros;
mod rt;

use defmt::info;
use embassy_executor::Spawner;
use error::Error;
use esp_backtrace as _;
use esp_hal::timer::systimer::SystemTimer;
use esp_println as _;

async fn main(_s: Spawner) -> Result<(), Error> {
    let p = esp_hal::init(<_>::default());
    let syst = SystemTimer::new(p.SYSTIMER);
    esp_hal_embassy::init(syst.alarm0);
    info!("HAL init!");

    Ok(())
}
