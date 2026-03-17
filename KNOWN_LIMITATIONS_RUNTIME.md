# KNOWN_LIMITATIONS_RUNTIME

- Sync-enabled daily use still depends on valid `SUPABASE_URL` and `SUPABASE_ANON_KEY` runtime configuration plus a reachable Supabase backend. This was not end-to-end verified in the current shell session.
- Notification delivery was not manually confirmed on Android or Windows during this pass. Initialization is hardened, but actual reminder delivery and tap navigation still require device-level verification.
- Android-specific flows involving notification permission prompts, Workmanager execution, and background reminder delivery were not manually exercised in this session.
- File-picker and save-dialog flows were hardened against platform exceptions, but actual dialog interaction on Windows and Android still needs manual verification.
- The technical package/binary identifiers remain `study_flow` for compatibility; user-facing branding has been renamed to `Cognitive Task Planning System`.
