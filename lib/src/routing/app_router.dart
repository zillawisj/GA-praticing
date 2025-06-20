import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/authentication/presentation/account/account_screen.dart';
import 'package:ecommerce_app/src/features/authentication/presentation/sign_in/email_password_sign_in_form_type.dart';
import 'package:ecommerce_app/src/features/authentication/presentation/sign_in/email_password_sign_in_screen.dart';
import 'package:ecommerce_app/src/features/cart/presentation/shopping_cart/shopping_cart_screen.dart';
import 'package:ecommerce_app/src/features/checkout/presentation/checkout_screen/checkout_screen.dart';
import 'package:ecommerce_app/src/features/orders/presentation/orders_list/orders_list_screen.dart';
import 'package:ecommerce_app/src/features/products/presentation/product_screen/product_screen.dart';
import 'package:ecommerce_app/src/features/products/presentation/products_list/products_list_screen.dart';
import 'package:ecommerce_app/src/features/reviews/presentation/leave_review_screen/leave_review_screen.dart';
import 'package:ecommerce_app/src/routing/go_router_refresh_stream.dart';
import 'package:ecommerce_app/src/routing/not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:ecommerce_app/src/utils/screen_analytics_manager.dart';
import 'package:ecommerce_app/src/utils/app_screen_enum.dart';

part 'app_router.g.dart';

enum AppRoute {
  home,
  product,
  leaveReview,
  cart,
  checkout,
  orders,
  account,
  signIn,
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final screenAnalytics = ScreenAnalyticsManager();

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authRepository.currentUser != null;
      final path = state.uri.path;
      if (isLoggedIn) {
        if (path == '/signIn') {
          return '/';
        }
      } else {
        if (path == '/account' || path == '/orders') {
          return '/';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        builder: (context, state) {
          final screen = AppScreenExtension.fromPath(state.uri.path);
          screenAnalytics.trackScreen(screen);
          return const ProductsListScreen();
        },
        routes: [
          GoRoute(
            path: 'product/:id',
            name: AppRoute.product.name,
            builder: (context, state) {
              final screen = AppScreenExtension.fromPath(state.uri.path);

              screenAnalytics.trackScreen(screen);
              final productId = state.pathParameters['id']!;
              return ProductScreen(productId: productId);
            },
            routes: [
              GoRoute(
                path: 'review',
                name: AppRoute.leaveReview.name,
                pageBuilder: (context, state) {
                  final screen = AppScreenExtension.fromPath(state.uri.path);

                  screenAnalytics.trackScreen(screen);
                  final productId = state.pathParameters['id']!;
                  return MaterialPage(
                    fullscreenDialog: true,
                    child: LeaveReviewScreen(productId: productId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'cart',
            name: AppRoute.cart.name,
            pageBuilder: (context, state) {
              final screen = AppScreenExtension.fromPath(state.uri.path);

              screenAnalytics.trackScreen(screen);
              return const MaterialPage(
                fullscreenDialog: true,
                child: ShoppingCartScreen(),
              );
            },
            routes: [
              GoRoute(
                path: 'checkout',
                name: AppRoute.checkout.name,
                pageBuilder: (context, state) {
                  final screen = AppScreenExtension.fromPath(state.uri.path);

                  screenAnalytics.trackScreen(screen);
                  return const MaterialPage(
                    fullscreenDialog: true,
                    child: CheckoutScreen(),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'orders',
            name: AppRoute.orders.name,
            pageBuilder: (context, state) {
              final screen = AppScreenExtension.fromPath(state.uri.path);

              screenAnalytics.trackScreen(screen);
              return const MaterialPage(
                fullscreenDialog: true,
                child: OrdersListScreen(),
              );
            },
          ),
          GoRoute(
            path: 'account',
            name: AppRoute.account.name,
            pageBuilder: (context, state) {
              final screen = AppScreenExtension.fromPath(state.uri.path);

              screenAnalytics.trackScreen(screen);
              return const MaterialPage(
                fullscreenDialog: true,
                child: AccountScreen(),
              );
            },
          ),
          GoRoute(
            path: 'signIn',
            name: AppRoute.signIn.name,
            pageBuilder: (context, state) {
              final screen = AppScreenExtension.fromPath(state.uri.path);

              screenAnalytics.trackScreen(screen);
              return const MaterialPage(
                fullscreenDialog: true,
                child: EmailPasswordSignInScreen(
                  formType: EmailPasswordSignInFormType.signIn,
                ),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      screenAnalytics.trackScreen(AppScreen.notFound);
      return const NotFoundScreen();
    },
  );
}







