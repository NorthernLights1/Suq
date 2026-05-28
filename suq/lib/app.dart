import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

class SuqApp extends ConsumerWidget {
  const SuqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(ref);
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }
}
