import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../routing/routes.dart';
import '../view_models/code_entry_viewmodel.dart';

class CodeEntryPage extends ConsumerWidget {
  final String? email;
  final String? name;
  const CodeEntryPage({super.key, this.email, this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(codeEntryViewModelProvider);
    // create controller locally (acceptable for this simple form)
    final codeC = TextEditingController();

    // trigger auto-send once; viewmodel internals avoid double-send
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.maybeAutoSend(email: email, name: name);
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Vérification'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Un code à 6 chiffres a été envoyé à ${vm.resolvedEmail ?? email ?? ''}',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: codeC,
                    decoration: const InputDecoration(
                      labelText: 'Code (6 chiffres)',
                    ),
                  ),
                  if (vm.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: vm.loading
                        ? null
                        : () async {
                            final code = codeC.text.trim().replaceAll(' ', '');
                            final success = await vm.submit(
                              code,
                              email: vm.resolvedEmail ?? email,
                            );
                            if (success) {
                              if (!context.mounted) return;
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRoutes.home);
                            }
                          },
                    child: vm.loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Valider'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
