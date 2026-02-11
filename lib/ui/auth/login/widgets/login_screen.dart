import 'package:econoris_app/ui/auth/login/view_models/login_state.dart';
import 'package:econoris_app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:econoris_app/ui/auth/login/widgets/code_entry_screen.dart';
import 'package:econoris_app/ui/auth/login/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginViewModelProvider);

    return Scaffold(
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        enterEmail: (email) => LoginForm(email: email, requireName: false),

        enterEmailAndName: (email) =>
            LoginForm(email: email, requireName: true),

        submitting: (_, _) => const Center(child: CircularProgressIndicator()),

        enterOtp: (email) => CodeEntryPage(email: email),

        error: (message) => Center(
          child: Text(message, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
