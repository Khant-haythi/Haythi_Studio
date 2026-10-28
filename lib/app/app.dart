import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

class HayThiStudioApp extends StatelessWidget {
  const HayThiStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HayThi Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
