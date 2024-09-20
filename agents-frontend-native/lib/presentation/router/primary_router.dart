import 'package:go_router/go_router.dart';

abstract class PrimaryRouter {
  GoRouter getRouter();

  void updateSplashRedirectionRoute(
    final String route,
  );
}
