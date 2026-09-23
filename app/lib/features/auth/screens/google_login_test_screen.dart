import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../../data/powersync/powersync_session_manager.dart';
import '../../splash/screens/splash_screen.dart';
import '../services/google_auth_service.dart';
import '../services/session_service.dart';

class GoogleLoginTestScreen extends StatefulWidget {
  const GoogleLoginTestScreen({super.key});

  @override
  State<GoogleLoginTestScreen> createState() => _GoogleLoginTestScreenState();
}

class _GoogleLoginTestScreenState extends State<GoogleLoginTestScreen> {
  final GoogleAuthService _authService = GoogleAuthService();
  late final SessionService _sessionService;
  late final PowerSyncSessionManager _powerSyncSessionManager;
  bool _isLoading = false;
  String? _errorMessage;
  KospiaSession? _session;
  bool _sessionRestored = false;

  @override
  void initState() {
    super.initState();
    _sessionService = context.read<SessionService>();
    _powerSyncSessionManager = context.read<PowerSyncSessionManager>();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await _sessionService.loadSession();
      if (!mounted) {
        return;
      }
      if (session != null && !_powerSyncSessionManager.hasActiveSession) {
        await _powerSyncSessionManager.activateSession(session);
      }
      setState(() {
        _session = session;
        _sessionRestored = session != null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo restaurar la sesión: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _session = null;
      _sessionRestored = false;
    });

    try {
      await _authService.authenticate();
      if (!mounted) return;

      final session = await _authService.authenticateWithKospiaBackend();
      if (!mounted) return;
      await _sessionService.saveSession(session);
      if (!mounted) return;
      await _powerSyncSessionManager.activateSession(session);
      if (!mounted) return;
      setState(() {
        _session = session;
      });
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Google Sign-In: ERROR\n${e.code}';
      });
    } on HttpException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      try {
        await _powerSyncSessionManager.deactivateSession();
      } finally {
        await _sessionService.clearSession();
      }
      try {
        await _authService.signOut();
      } catch (_) {
        rethrow;
      }
      setState(() {
        _session = null;
        _sessionRestored = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo cerrar sesión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _continueToKospia() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_session == null)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSignIn,
                    icon: const Icon(Icons.login),
                    label: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continuar con Google'),
                  )
                else ...[
                  if (_sessionRestored)
                    const Text(
                      'Sesión restaurada correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    )
                  else ...[
                    const Text(
                      'Google Sign-In: OK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Backend Kospia: OK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Sesión Kospia: OK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Kospia user ID: ${_session!.userId}'),
                  Text('Email: ${_session!.email}'),
                  Text('Display name: ${_session!.displayName}'),
                  Text('Photo URL: ${_session!.photoUrl}'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _continueToKospia,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continuar a Kospia'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
