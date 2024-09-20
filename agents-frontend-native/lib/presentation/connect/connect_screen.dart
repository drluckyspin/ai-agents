import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hp_live_kit/common/constant.dart';
import 'package:hp_live_kit/di/service_locator.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_bloc.dart';
import 'package:hp_live_kit/presentation/connect/bloc/connect_state.dart';
import 'package:hp_live_kit/presentation/router/primary_route.dart';
import 'package:hp_live_kit/presentation/theme/dimen.dart';
import 'package:hp_live_kit/presentation/theme/text_size.dart';

import '../widgets/text_input_field.dart';
import 'bloc/connect_event.dart';

class ConnectScreen extends StatelessWidget {
  ConnectScreen({super.key});

  static const tokenEnvKey = 'TOKEN';
  static const serverUrlKey = 'URL';

  final _serverURLTextController = TextEditingController();
  final _tokenTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _readEnvironmentVariables();
    return BlocProvider<ConnectBloc>(
      create: (_) => serviceLocator.get<ConnectBloc>(),
      child: BlocListener<ConnectBloc, ConnectState>(
        listenWhen: (previousState, state) => state is Success,
        listener: (context, state) => _navigateToMainScreen(context),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Connect to LiveKit',
              style: TextStyle(color: Colors.black),
            ),
          ),
          body: BlocBuilder<ConnectBloc, ConnectState>(
            builder: (context, state) {
              if (state is Loading) {
                return Container(
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()));
              } else if (state is Success) {}
              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(Dimen.spacingL),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimen.spacingXl),
                        child: HPTextInputField(
                          label: 'Server URL',
                          textEditingController: _serverURLTextController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: Dimen.spacingXl),
                        child: HPTextInputField(
                          label: 'Token',
                          textEditingController: _tokenTextController,
                        ),
                      ),
                      FilledButton(
                        onPressed: () => _handleOnContinuePressed(context),
                        child: const Text(
                          'Connect',
                          style: TextStyle(fontSize: TextSize.buttonTextSize),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleOnContinuePressed(BuildContext context) {
    context.read<ConnectBloc>().add(
          ConnectRemotely(
              serverURL: _serverURLTextController.text,
              token: _tokenTextController.text),
        );
  }

  void _readEnvironmentVariables() {
    _serverURLTextController.text = const bool.hasEnvironment(serverUrlKey)
        ? const String.fromEnvironment(serverUrlKey)
        : Constant.emptyString;
    _tokenTextController.text = const bool.hasEnvironment(tokenEnvKey)
        ? const String.fromEnvironment(tokenEnvKey)
        : Constant.emptyString;
  }

  void _navigateToMainScreen(BuildContext context) {
    context.pushReplacement(
      PrimaryRoute.home.path,
    );
  }
}
