import 'package:go_router/go_router.dart';
import 'package:hp_live_kit/presentation/connect/connect_screen.dart';
import 'package:hp_live_kit/presentation/home/home_screen.dart';
import 'package:hp_live_kit/presentation/router/primary_route.dart';
import 'package:hp_live_kit/presentation/router/primary_router.dart';

class PrimaryRouterImpl implements PrimaryRouter {
  late final GoRouter _router;
  String _splashRedirectionRoute = PrimaryRoute.home.path;

  PrimaryRouterImpl(this._router);

  PrimaryRouterImpl.defaultRouter() {
    _router = GoRouter(
      routes: [_splashRoute(), _connectRoute(), _homeRoute()],
    );
  }

  @override
  GoRouter getRouter() => _router;

  @override
  void updateSplashRedirectionRoute(String route) =>
      _splashRedirectionRoute = route;

  RouteBase _splashRoute() => GoRoute(
        name: PrimaryRoute.splash.routeName,
        path: PrimaryRoute.splash.path,
        redirect: (_, __) {
          return _splashRedirectionRoute;
        },
      );

  RouteBase _connectRoute() => GoRoute(
        name: PrimaryRoute.connect.routeName,
        path: PrimaryRoute.connect.path,
        builder: (_, __) => ConnectScreen(),
      );

  RouteBase _homeRoute() => GoRoute(
        name: PrimaryRoute.home.routeName,
        path: PrimaryRoute.home.path,
        builder: (_, __) => const HomeScreen(),
      );
}
