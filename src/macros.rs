//! helper macros.

// TODO: this should ultimately be a derive macro.
/// define an error enum in the current scope.
#[macro_export]
macro_rules! error_def {
  ($($variant:ident => $inner:ty = $msg:expr),+ $(,)?) => {
    #[derive(Clone)]
    pub enum Error {
      $($variant($inner)),+
    }

    $(
      impl ::core::convert::From<$inner> for Error {
        fn from(inner: $inner) -> Self {
          Self::$variant(inner)
        }
      }
    )+

    impl ::defmt::Format for Error {
      fn format(&self, fmt: ::defmt::Formatter<'_>) {
        $crate::error_def! {
          __private self, fmt => $($variant => $inner => $msg;)+
        }
      }
    }
  };

  (__private $self:expr, $fmt:expr =>) => {};
  (__private $self:expr, $fmt:expr =>
    $variant:ident => $inner:ty => $msg:literal; $($tail:tt)*) =>
  {
    $crate::error_def! {
      __private $self, $fmt =>
        $variant => $inner => |fmt, inner| ::defmt::write!(fmt, $msg, inner);
      $($tail)*
    }
  };
  (__private $self:expr, $fmt:expr =>
    $variant:ident => $inner:ty => $msg:expr; $($tail:tt)*) =>
  {
    if let Self::$variant(inner) = $self {
      let f: impl Fn(::defmt::Formatter<'_>, &$inner) = $msg;
      return f($fmt, inner);
    }

    $crate::error_def! { __private $self, $fmt => $($tail)* }
  };
}

/// get a `&'static mut T`.
#[macro_export]
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
