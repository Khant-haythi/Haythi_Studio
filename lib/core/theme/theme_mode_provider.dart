import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preferences_provider.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.watch(preferencesProvider)?.getString('theme_mode');
    return ThemeMode.values.firstWhere((mode) => mode.name == saved,
        orElse: () => ThemeMode.system);
  }

  Future<void> select(ThemeMode mode) async {
    final preferences = ref.read(preferencesProvider);
    if (preferences != null &&
        !await preferences.setString('theme_mode', mode.name)) {
      throw StateError('Could not save appearance');
    }
    state = mode;
  }
}
