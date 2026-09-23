import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powersync/powersync.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/powersync/powersync_session_manager.dart';
import 'data/repositories/species_repository.dart';
import 'data/repositories/observation_repository.dart';
import 'features/auth/services/session_service.dart';
import 'features/auth/screens/google_login_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Modo edge-to-edge: la app dibuja detras de las barras del sistema, sin
  // franjas negras. La status bar queda transparente con iconos oscuros para
  // integrarse con el fondo lila de marca (fondo claro -> iconos oscuros).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final database = AppDatabase();
  final sessionService = SessionService();
  final powerSyncSessionManager = PowerSyncSessionManager(sessionService);
  final restoredSession = await sessionService.loadSession();
  if (restoredSession != null) {
    try {
      await powerSyncSessionManager.activateSession(restoredSession);
    } catch (error) {
      debugPrint('PowerSync: no se pudo restaurar la sesión: $error');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider<PowerSyncSessionManager>.value(
          value: powerSyncSessionManager,
        ),
        Provider<SessionService>.value(value: sessionService),
      ],
      child: const KospiaApp(),
    ),
  );
}

class KospiaApp extends StatelessWidget {
  const KospiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<PowerSyncSessionManager>();
    final powerSyncDatabase = manager.database;
    final driftDatabase = context.read<AppDatabase>();
    final sessionService = context.read<SessionService>();

    final app = MaterialApp(
      title: 'Kospia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const GoogleLoginTestScreen(),
    );

    if (powerSyncDatabase == null) {
      return app;
    }

    return MultiProvider(
      providers: [
        Provider<PowerSyncDatabase>.value(value: powerSyncDatabase),
        Provider<SpeciesRepository>(
          create: (_) => SpeciesRepository(driftDatabase, powerSyncDatabase),
        ),
        ChangeNotifierProvider<ObservationRepository>(
          create: (_) => ObservationRepository(
            powerSyncDatabase,
            manager.attachmentUploadService!,
            sessionService,
          ),
        ),
      ],
      child: app,
    );
  }
}
