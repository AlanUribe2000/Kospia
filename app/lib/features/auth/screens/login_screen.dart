import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final isLoading = controller.isLoading;
    final hasError = controller.status == AuthStatus.error;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Kospia',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.accentGreen,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Identificá y registrá la flora patagónica\nque encontrás a tu alrededor.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textMedium,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (hasError) ...[
                      const Text(
                        'No pudimos iniciar sesión. Verificá tu conexión e intentá nuevamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => controller.signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textDark,
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          side: const BorderSide(
                            color: Color(0xFFDADCE0),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.textMedium,
                                ),
                              )
                            else
                              Image.asset(
                                'assets/images/google_g_logo.png',
                                width: 20,
                                height: 20,
                              ),
                            const SizedBox(width: 12),
                            Text(
                              isLoading
                                  ? 'Iniciando sesión...'
                                  : 'Continuar con Google',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tu sesión y tus registros se mantienen seguros en tu dispositivo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
