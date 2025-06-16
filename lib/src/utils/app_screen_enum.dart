enum AppScreen {
  home,
  product,
  leaveReview,
  cart,
  checkoutRegister,
  checkoutPayment,
  orders,
  account,
  signIn,
  notFound,
}

extension AppScreenExtension on AppScreen {
  String get screenName {
    switch (this) {
      case AppScreen.home:
        return 'HomeScreen';
      case AppScreen.product:
        return 'ProductDetailScreen';
      case AppScreen.leaveReview:
        return 'ReviewScreen';
      case AppScreen.cart:
        return 'ShoppingCartScreen';
      case AppScreen.checkoutRegister:
        return 'CheckoutRegisterScreen';
      case AppScreen.checkoutPayment:
        return 'CheckoutPaymentScreen';
      case AppScreen.orders:
        return 'OrdersScreen';
      case AppScreen.account:
        return 'AccountScreen';
      case AppScreen.signIn:
        return 'SignInScreen';
      case AppScreen.notFound:
        return 'NotFoundScreen';
    }
  }

  /// Optional helper to get from GoRouter path
  static AppScreen fromPath(String path) {
    if (path == '/' || path == '/home') return AppScreen.home;
    if (path.startsWith('/product/')) return AppScreen.product;
    if (path.startsWith('/product/') && path.endsWith('/review')) return AppScreen.leaveReview;
    if (path == '/cart') return AppScreen.cart;
    if (path == '/cart/checkout') return AppScreen.checkoutRegister; // assume initial
    if (path == '/orders') return AppScreen.orders;
    if (path == '/account') return AppScreen.account;
    if (path == '/signIn') return AppScreen.signIn;
    return AppScreen.notFound;
  }
}
