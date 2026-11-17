import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/preferences_provider.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [preferencesProvider.overrideWithValue(preferences)],
    child: const HayThiStudioApp(),
  ));
}
