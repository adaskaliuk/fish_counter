import 'package:firebase_auth/firebase_auth.dart';
import 'package:fish_counter/l10n/app_localizations.dart';
import 'package:fish_counter/services/prefs_repository.dart';
import 'package:fish_counter/widgets/auth_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract final class AuthScreenStateKeys {
  static const emailFieldKey = ValueKey('auth_email_field');
  static const passwordFieldKey = ValueKey('auth_password_field');
  static const submitButtonKey = ValueKey('auth_submit_button');
  static const googleButtonKey = ValueKey('auth_google_button');
  static const guestButtonKey = ValueKey('auth_guest_button');
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isRegister = false;
  bool _isLoading = false;
  String? _error;
  String? _role;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final auth = widget.auth ?? FirebaseAuth.instance;
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;

      if (_isRegister) {
        if (_role == null) {
          setState(() => _error = l10n.roleRequired);
          return;
        }
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final repo = await PrefsRepository.create();
        final userId = auth.currentUser?.uid;
        final existing = repo.loadAthleteProfile(userId: userId);
        await repo.saveAthleteProfile(
          existing.copyWith(role: _role!),
          userId: userId,
        );
      } else {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.authenticationFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      final provider = GoogleAuthProvider();

      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await GoogleSignIn.instance.initialize();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.authenticationFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final l10n = AppLocalizations.of(context);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.authenticationFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 32),
                  TextField(
                    key: AuthScreenStateKeys.emailFieldKey,
                    controller: _emailCtrl,
                    decoration: InputDecoration(labelText: l10n.email),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: AuthScreenStateKeys.passwordFieldKey,
                    controller: _passwordCtrl,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      hint: Text(l10n.roleLabel),
                      items: [
                        DropdownMenuItem(
                          value: 'athlete',
                          child: Text(l10n.roleAthlete),
                        ),
                        DropdownMenuItem(
                          value: 'coach',
                          child: Text(l10n.roleCoach),
                        ),
                      ],
                      onChanged: (value) => setState(() => _role = value),
                      decoration: InputDecoration(labelText: l10n.roleLabel),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_error != null) AuthErrorMessage(_error!),
                  LoadingButton(
                    key: AuthScreenStateKeys.submitButtonKey,
                    label: _isRegister ? l10n.register : l10n.signIn,
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister ? l10n.haveAccount : l10n.needAccount,
                    ),
                  ),
                  const Divider(height: 32),
                  OutlinedButton.icon(
                    key: AuthScreenStateKeys.googleButtonKey,
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata),
                    label: Text(l10n.continueWithGoogle),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: AuthScreenStateKeys.guestButtonKey,
                    onPressed: _isLoading ? null : _continueAsGuest,
                    child: Text(l10n.continueAsGuest),
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
