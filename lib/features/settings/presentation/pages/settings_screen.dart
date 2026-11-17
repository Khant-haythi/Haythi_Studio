import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/providers/app_language_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(appLanguageProvider);
    final burmese = language == AppLanguage.burmese;
    return Scaffold(
      appBar: AppBar(title: Text(burmese ? 'ဆက်တင်များ' : 'Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(burmese ? 'အပြင်အဆင်' : 'Appearance',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile.adaptive(
            secondary: Icon(
                dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            title: Text(burmese ? 'အမှောင်မုဒ်' : 'Dark mode'),
            subtitle: Text(burmese
                ? (dark ? 'အမှောင်အပြင်အဆင်' : 'အလင်းအပြင်အဆင်')
                : (dark ? 'Dark appearance' : 'Light appearance')),
            value: dark,
            activeTrackColor: const Color(0xFF8F4B5C),
            onChanged: (enabled) async {
              try {
                await ref
                    .read(themeModeProvider.notifier)
                    .select(enabled ? ThemeMode.dark : ThemeMode.light);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Could not save appearance. Please try again.')));
                }
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Text(burmese ? 'ဘာသာစကား' : 'Language',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
            child: ListTile(
          leading: const Icon(Icons.language_rounded),
          title: Text(burmese ? 'ဘာသာစကား ပြောင်းရန်' : 'Change language'),
          subtitle: Text(burmese ? 'မြန်မာ' : 'English'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () async {
            final selected = await showModalBottomSheet<AppLanguage>(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) => SafeArea(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      for (final option in AppLanguage.values)
                        ListTile(
                          title: Text(option == AppLanguage.english
                              ? 'English'
                              : 'မြန်မာ'),
                          trailing: language == option
                              ? const Icon(Icons.check_rounded)
                              : null,
                          onTap: () => Navigator.pop(sheetContext, option),
                        ),
                      const SizedBox(height: 16),
                    ])));
            if (selected != null && context.mounted) {
              try {
                await ref.read(appLanguageProvider.notifier).select(selected);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text('Could not save language. Please try again.')));
                }
              }
            }
          },
        )),
      ]),
    );
  }
}
