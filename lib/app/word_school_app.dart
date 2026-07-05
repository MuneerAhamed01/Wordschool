import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/app_theme.dart';
import 'package:wordshool/core/config/app_config.dart';

class WordSchoolApp extends StatelessWidget {
  const WordSchoolApp({
    super.key,
    required this.router,
    required this.appConfig,
  });

  final GoRouter router;
  final AppConfig appConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appConfig.displayName,
      theme: AppTheme.gameDark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
