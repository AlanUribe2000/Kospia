import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kospia/data/powersync/powersync_session_manager.dart';
import 'package:kospia/features/auth/controllers/auth_controller.dart';
import 'package:kospia/features/auth/services/google_auth_service.dart';
import 'package:kospia/features/auth/services/session_service.dart';
import 'package:kospia/features/auth/widgets/auth_gate.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AuthGate shows the unauthenticated view', (tester) async {
    final sessionService = SessionService();
    final manager = PowerSyncSessionManager(sessionService);
    final controller = AuthController(
      sessionService,
      GoogleAuthService(),
      manager,
    );
    addTearDown(controller.dispose);
    addTearDown(manager.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: controller,
        child: MaterialApp(
          home: AuthGate(
            unauthenticatedBuilder: (_) => const Text('Login'),
            authenticatedBuilder: (_) => const Text('Authenticated'),
          ),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Authenticated'), findsNothing);
  });
}
