import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/theme_mode_provider.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class HayThiStudioApp extends ConsumerWidget {
  const HayThiStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HayThi Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
    );
  }
}
