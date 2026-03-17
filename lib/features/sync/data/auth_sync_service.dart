import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/sync_models.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> initializeSyncBackend() async {
  if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
    return;
  }
  if (AuthSyncService.isConfigured) {
    return;
  }

  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
}

class AuthSyncService {
  const AuthSyncService();

  static bool get isConfigured =>
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;

  SupabaseClient? get _client {
    if (!isConfigured) {
      return null;
    }

    try {
      return Supabase.instance.client;
    } catch (_) {
      // Safe fallback: let the app continue offline if Supabase init failed.
      return null;
    }
  }

  SyncAccountSummary getCurrentAccount() {
    final client = _client;
    final user = client?.auth.currentUser;
    return SyncAccountSummary(
      isConfigured: isConfigured,
      isSignedIn: user != null,
      userId: user?.id,
      email: user?.email,
    );
  }

  Stream<SyncAccountSummary> watchAccount() {
    final client = _client;
    if (client == null) {
      return Stream.value(getCurrentAccount());
    }

    return client.auth.onAuthStateChange.map((_) => getCurrentAccount());
  }

  Future<void> signIn({required String email, required String password}) async {
    final client = _requireClient();
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    final client = _requireClient();
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) {
      return;
    }
    await client.auth.signOut();
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw StateError(
        'Sync backend is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
      );
    }
    return client;
  }
}
