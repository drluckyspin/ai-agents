import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hp_live_kit/data/local/environment_params_service.dart';
import 'package:hp_live_kit/data/local/environment_params_service_impl.dart';
import 'package:hp_live_kit/data/remote/network/network_service.dart';
import 'package:hp_live_kit/data/remote/network/network_service_impl.dart';
import 'package:hp_live_kit/data/reporistory/livekit/room_repository.dart';
import 'package:hp_live_kit/data/reporistory/livekit/room_repository_impl.dart';
import 'package:hp_live_kit/data/reporistory/token/token_repository.dart';
import 'package:hp_live_kit/data/remote/livekit/room_service.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_bloc.dart';
import 'package:hp_live_kit/presentation/home/bloc/home_bloc.dart';
import 'package:hp_live_kit/presentation/router/primary_route_impl.dart';
import 'package:hp_live_kit/presentation/router/primary_router.dart';
import 'package:hp_live_kit/presentation/settings/settings_controller.dart';

import '../data/reporistory/token/token_repository_impl.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  _registerBlocs();
  _registerRouter();
  _registerNetworkClients();
  _registerRepositories();
  _registerServices();
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
  serviceLocator.registerFactory<SettingsController>(
    () => SettingsController(serviceLocator()),
  );
  serviceLocator.registerFactory<HomeBloc>(
    () => HomeBloc(serviceLocator()),
  );
}

void _registerNetworkClients() {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(serviceLocator()));
}

void _registerRepositories() {
  serviceLocator.registerFactory<TokenRepository>(
    () => TokenRepositoryImpl(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory<RoomRepository>(
    () => RoomRepositoryImpl(
        serviceLocator(), serviceLocator(), serviceLocator()),
  );
}

void _registerServices() {
  serviceLocator.registerSingleton<RoomService>(RoomService());
  serviceLocator.registerSingleton<EnvironmentParamsService>(
      EnvironmentParamsServiceImpl());
}
