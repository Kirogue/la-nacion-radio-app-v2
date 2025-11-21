import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './splash_wrapper.dart';

// Config
import 'package:la_nacion/config/app_theme.dart';
import 'package:la_nacion/config/constants.dart';

// Controllers
import 'package:la_nacion/dashboard/controllers/ads_controller.dart';
import 'package:la_nacion/dashboard/controllers/companies_controller.dart';
import 'package:la_nacion/dashboard/controllers/navigation_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';
import 'package:la_nacion/dashboard/controllers/reels_controller.dart';
import 'package:la_nacion/dashboard/controllers/wp_api_controller.dart';
import 'package:la_nacion/dashboard/controllers/mini_player_controller.dart';

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WpApiController('')),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => CompaniesController()),
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => RadioController()),
        ChangeNotifierProvider(create: (_) => ReelsController()),
        ChangeNotifierProvider(create: (_) => AdsController()),
        ChangeNotifierProvider(create: (_) => MiniPlayerController()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navigationController, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: appTheme,
          navigatorKey: navigationController.navigatorKey,
          home: const SplashWrapper(),
        );
      },
    );
  }
}
