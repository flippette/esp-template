//! Runtime setup and background tasks.

use crate::error::Report;
use core::panic::PanicInfo;
use defmt::{error, info, intern};
use embassy_executor::Spawner;
use esp_hal_embassy::main;
use heapless::Vec;

#[main]
async fn _start(s: Spawner) {
    if let Err(rep) = crate::main(s).await {
        soft_panic(rep);
    }

    info!("main exited!");
}

/// Report the error and hang forever, without touching the [`panic!`]
/// machinery.
pub fn soft_panic<const N: usize>(rep: Report<N>) -> ! {
    error!("fatal error: {}", rep.error);
    error!("backtrace:");
    rep.backtrace.iter().for_each(|loc| error!("  {}", loc));
    if rep.more {
        error!("  (rest of backtrace omitted)");
    }

    loop {
        riscv::interrupt::disable();
        riscv::asm::wfi();
    }
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    let mut backtrace = Vec::new();
    info.location()
        .and_then(|loc| backtrace.push(loc.into()).ok());

    soft_panic(Report::<1> {
        error: intern!("panic").into(),
        backtrace,
        more: false,
    })
}
