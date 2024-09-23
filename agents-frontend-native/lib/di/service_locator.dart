import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hp_live_kit/data/network/network_service.dart';
import 'package:hp_live_kit/data/network/network_service_impl.dart';
import 'package:hp_live_kit/data/reporistory/token_repository.dart';
import 'package:hp_live_kit/data/room/room_service.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_bloc.dart';
import 'package:hp_live_kit/presentation/router/primary_route_impl.dart';
import 'package:hp_live_kit/presentation/router/primary_router.dart';
import 'package:hp_live_kit/presentation/settings/settings_controller.dart';

import '../data/reporistory/token_repository_impl.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  _registerBlocs();
  _registerRouter();
  _registerNetworkClients();
  _registerRepositories();
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
}

void _registerNetworkClients() {
  serviceLocator.registerSingleton<Dio>(Dio());
  serviceLocator.registerLazySingleton<NetworkService>(
      () => NetworkServiceImpl(serviceLocator()));
}

void _registerRepositories() {
  serviceLocator.registerFactory<TokenRepository>(
    () => TokenRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerSingleton<RoomService>(RoomService());
}
