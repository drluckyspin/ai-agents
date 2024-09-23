import 'package:flutter/material.dart';
import 'package:hp_live_kit/presentation/home/home_screen.dart';
import 'package:hp_live_kit/presentation/settings/settings_screen.dart';

import '../../common/constant.dart';
import '../connect/connect_screen.dart';

enum PrimaryRoute {
  splash(SizedBox),
  connect(ConnectScreen),
  home(HomeScreen),
  settings(SettingsScreen);

  const PrimaryRoute(this._routeType);

  final Type _routeType;

  String get path {
    if (this == PrimaryRoute.splash) {
      return Constant.slash;
    } else {
      return "${Constant.slash}$routeName";
    }
  }

  String get routeName => "$_routeType";
}
