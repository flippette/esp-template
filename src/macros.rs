//! helper macros.

/// register a fallible main function.
///
/// the function this attribute is applied on must:
/// - not be generic
/// - take exactly one _named_ argument of type [`embassy_executor::Spawner`].
/// - return some type that implements [`crate::error::Force`].
#[macro_export]
macro_rules! main {
  attr() (
    $(#[$attr:meta])*
    $vis:vis async fn $name:ident(
      $spawner:ident: $spawner_ty:ty $(,)?
    ) $(-> $return_ty:ty)?
    $body:block
  ) => {
    #[::esp_rtos::main]
    $vis async fn main(spawner: ::embassy_executor::Spawner) {
      $(#[$attr])*
      async fn $name($spawner: $spawner_ty) $(-> $return_ty)?
        $body

      #[allow(unreachable_code)]
      $crate::error::Force::force($name(spawner).await);
      ::defmt::info!("main exited!");
    }
  }
}

/// impl `From` and [`defmt::Format`] for an error enum.
///
/// functions that want to return `Result<_, ()>::Err` should instead define a
/// dedicated error type, then add it as a variant to the error enum; that way,
/// you avoid implementing `From<()>` twice for the error enum.
///
/// unfortunately, you can't put any attributes on variants (including doc
/// comments) other than `#[format(_)]`; this restriction may be lifted if the
/// macro is converted to be a proc macro in the future.
#[macro_export]
macro_rules! error {
  (
    $(#[$attr:meta])*
    $vis:vis enum $name:ident {
      $(
        $(#[doc = $doc:literal])*
        $(#[cfg($cfg:meta)])*
        $(#[format($format:ident)])?
        $var:ident ($from:ty) => $fmt:tt
      ),* $(,)?
    }
  ) => {
    $(#[$attr])*
    $vis enum $name {
      $(
        $(#[cfg($cfg)])*
        $(#[doc = $doc])*
        $var($from)
      ),*
    }

    $(
      $(#[cfg($cfg)])*
      impl ::core::convert::From<$from> for $name {
        fn from(inner: $from) -> Self {
          Self::$var(inner)
        }
      }
    )*

    impl ::defmt::Format for $name {
      fn format(&self, f: ::defmt::Formatter<'_>) {
        match self {
          $(
            $(#[cfg($cfg)])*
            Self::$var(_inner) => $crate::error!(
              @priv @format_impl $(#[format($format)])?
              $var(_inner) => f, $fmt
            )
          ),*
        }
      }
    }
  };

  // format string with one argument
  (@priv @format_impl
    $var:ident ($inner:expr) => $w:expr, $fmt:literal $(,)?
  ) => { ::defmt::write!($w, $fmt, $inner) };
  // format string with no arguments
  (@priv @format_impl
    #[format(lit)] $var:ident ($inner:expr) => $w:expr, $msg:literal $(,)?
  ) => { ::defmt::write!($w, $msg) };
  // format function (impl Fn(::defmt::Formatter<'_>, $inner) -> ())
  (@priv @format_impl
    #[format(fun)] $var:ident ($inner:expr) => $w:expr, $fmt:expr $(,)?
  ) => { $fmt($w, $inner) };
}

/// get a `&'static mut T`.
///
/// there are 2 variants of this macro:
///
/// - `const <type> = <expr>`: create a [`static_cell::ConstStaticCell`] with
///   some `const` initial value.
/// - `<type> = <expr>`: create a [`static_cell::StaticCell`] with some
///   non-`const` initial value.
///
/// all variants support passing additional attributes at the beginning.
#[macro_export]
macro_rules! make_static {
  ($(#[$m:meta])* const $type:ty = $val:expr) => {{
    $(#[$m])*
    static __CELL: ::static_cell::ConstStaticCell<$type> =
      ::static_cell::ConstStaticCell::new($val);
    __CELL.take()
  }};

  ($(#[$m:meta])* $type:ty = $val:expr) => {{
    $(#[$m])*
    static __CELL: ::static_cell::StaticCell<$type> =
      ::static_cell::StaticCell::new();
    __CELL.uninit().write($val)
  }};
}
