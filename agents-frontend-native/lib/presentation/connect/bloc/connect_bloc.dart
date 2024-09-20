import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_event.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_state.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  ConnectBloc() : super(Initial()) {
    on<ConnectRemotely>(_emitConnectRemotely);
  }

  FutureOr<void> _emitConnectRemotely(
      ConnectRemotely event, Emitter<ConnectState> emit) async {
    print("_emitConnectRemotely");
    emit(Loading());
    print("await");

    await Future.delayed(const Duration(seconds: 2));

    emit(Success());
  }
}
