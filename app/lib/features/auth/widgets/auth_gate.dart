import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.unauthenticatedBuilder,
    required this.authenticatedBuilder,
  });

  final WidgetBuilder unauthenticatedBuilder;
  final WidgetBuilder authenticatedBuilder;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    switch (controller.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return unauthenticatedBuilder(context);
      case AuthStatus.authenticated:
        return authenticatedBuilder(context);
      case AuthStatus.error:
        return _AuthErrorView(onRetry: controller.restoreSession);
    }
  }
}

class _AuthErrorView extends StatelessWidget {
  const _AuthErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No se pudo preparar la sesión.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
