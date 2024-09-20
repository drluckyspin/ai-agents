import 'package:get_it/get_it.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_bloc.dart';
import 'package:hp_live_kit/presentation/router/primary_route_impl.dart';
import 'package:hp_live_kit/presentation/router/primary_router.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  _registerBlocs();
  _registerRouter();
}

T get<T extends Object>() {
  return serviceLocator.get<T>();
}

void _registerRouter() {
  serviceLocator.registerLazySingleton<PrimaryRouter>(
    () => PrimaryRouterImpl.defaultRouter(),
  );
}

void _registerBlocs() {
  serviceLocator.registerFactory<ConnectBloc>(
    () => ConnectBloc(),
  );
}
