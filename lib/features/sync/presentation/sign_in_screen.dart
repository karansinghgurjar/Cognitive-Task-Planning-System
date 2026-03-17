import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';
import '../providers/sync_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _createAccount = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(syncActionControllerProvider);
    final account = ref.watch(syncAccountProvider).valueOrNull;
    final configured = account?.isConfigured ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                configured
                    ? 'Sign in with your personal sync account.'
                    : 'Supabase sync is not configured. Start the app with SUPABASE_URL and SUPABASE_ANON_KEY dart defines.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required.';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Use at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Create account'),
                subtitle: const Text('Turn this on to register instead of signing in.'),
                value: _createAccount,
                onChanged: configured
                    ? (value) => setState(() => _createAccount = value)
                    : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: !configured || actionState.isLoading ? null : _submit,
                icon: Icon(_createAccount ? Icons.person_add_alt_1 : Icons.login_rounded),
                label: Text(_createAccount ? 'Create Account' : 'Sign In'),
              ),
              if (actionState.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  ErrorHandler.mapError(actionState.error!).message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (_createAccount) {
        await ref
            .read(syncActionControllerProvider.notifier)
            .signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      } else {
        await ref
            .read(syncActionControllerProvider.notifier)
            .signIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
    }
  }
}


