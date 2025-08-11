//! helper macros.

/// impl `From` and [`defmt::Format`] for an error enum.
///
/// functions that want to return `Result<_, ()>::Err` should instead define a
/// dedicated error type, then add it as a variant to the error enum; that way,
/// you avoid implementing `From<()>` twice for the error enum.
///
/// unfortunately, you can't put any attributes on variants (including doc
/// comments) other than `#[format(_)]`; this restriction may be lifted if the
/// macro is converted to be a proc macro in the future.
macro_rules! error {
  (
    $(#[$attr:meta])*
    $vis:vis enum $name:ident {
      $(
        $(#[format($format:ident)])?
        $var:ident ($from:ty) => $fmt:tt
      ),* $(,)?
    }
  ) => {
    $(#[$attr])*
    $vis enum $name {
      $($var($from)),*
    }

    $(
      impl ::core::convert::From<$from> for $name {
        fn from(inner: $from) -> Self {
          Self::$var(inner)
        }
      }
    )*

    impl ::defmt::Format for $name {
      fn format(&self, f: ::defmt::Formatter<'_>) {
        match self {
          $(Self::$var(inner) => $crate::macros::error!(@priv @format_impl
            $(#[format($format)])? $var(inner) => f, $fmt)),*
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
macro_rules! make_static {
  // runtime-init
  ($(#[$m:meta])* $type:ty = $val:expr) => {{
    $(#[$m])*
    static __CELL: ::static_cell::StaticCell<$type> =
      ::static_cell::StaticCell::new();
    __CELL.uninit().write($val)
  }};

  // const-init
  ($(#[$m:meta])* const $type:ty = $val:expr) => {{
    $(#[$m])*
    static __CELL: ::static_cell::ConstStaticCell<$type> =
      ::static_cell::ConstStaticCell::new($val);
    __CELL.take()
  }};
}

pub(crate) use {error, make_static};
