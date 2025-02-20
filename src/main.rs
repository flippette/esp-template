#![no_std]
#![no_main]
#![feature(generic_arg_infer, impl_trait_in_assoc_type, impl_trait_in_bindings)]
#![expect(unstable_features)]

mod error;
mod macros;
mod rt;

use defmt::info;
use defmt_rtt as _;
use embassy_executor::Spawner;
use error::Report;
use esp_backtrace as _;
use esp_hal::timer::systimer::SystemTimer;

async fn main(_s: Spawner) -> Result<(), Report<8>> {
    let p = esp_hal::init(<_>::default());
    esp_hal_embassy::init(SystemTimer::new(p.SYSTIMER).alarm0);
    info!("HAL init!");

    Ok(())
}
