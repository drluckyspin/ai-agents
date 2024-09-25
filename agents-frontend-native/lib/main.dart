import 'package:flutter/material.dart';
import 'package:hp_live_kit/data/local/environment_params_service.dart';
import 'package:hp_live_kit/presentation/router/primary_router.dart';
import 'di/service_locator.dart' as service_locator;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await service_locator.init();
  await service_locator.get<EnvironmentParamsService>().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: service_locator.get<PrimaryRouter>().getRouter(),
      debugShowCheckedModeBanner: false,
      title: 'COOL Agent',
    );
  }
}
