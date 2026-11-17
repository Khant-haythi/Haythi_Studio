import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'preferences_provider.dart';

enum AppLanguage { english, burmese }

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
        AppLanguageController.new);

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final saved = ref.watch(preferencesProvider)?.getString('app_language');
    return AppLanguage.values.firstWhere((language) => language.name == saved,
        orElse: () => AppLanguage.english);
  }

  Future<void> select(AppLanguage language) async {
    final preferences = ref.read(preferencesProvider);
    if (preferences != null &&
        !await preferences.setString('app_language', language.name)) {
      throw StateError('Could not save language');
    }
    state = language;
  }
}
