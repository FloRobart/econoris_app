import 'package:econoris_app/ui/core/themes/theme.dart';
import 'package:econoris_app/ui/core/themes/theme_controller.dart';
import 'package:econoris_app/ui/core/ui/widgets/card_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeModeAsync = ref.watch(themeControllerProvider);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.color_lens, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Thème', style: theme.textTheme.titleMedium),
              const Spacer(),
              themeModeAsync.when(
                data: (themeMode) => DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      ref
                          .read(themeControllerProvider.notifier)
                          .setMode(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Système'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Clair'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Sombre'),
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (e, s) =>
                    const Icon(Icons.error, color: AppTheme.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
