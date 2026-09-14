import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:powersync/powersync.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/powersync/attachment_upload_service.dart';
import 'data/powersync/powersync_database.dart';
import 'data/repositories/species_repository.dart';
import 'data/repositories/observation_repository.dart';
import 'features/splash/screens/splash_screen.dart';

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
  final powerSyncDatabase = await openKospiaPowerSyncDatabase();
  final attachmentUploadService = AttachmentUploadService(powerSyncDatabase);

  connectKospiaPowerSync(powerSyncDatabase).catchError((error) {
    debugPrint('PowerSync: error de conexion: $error');
  });
  attachmentUploadService.uploadPending().catchError((error) {
    debugPrint('Attachments: error procesando pendientes: $error');
  });
  attachmentUploadService.startConnectivityListener();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<PowerSyncDatabase>.value(value: powerSyncDatabase),
        Provider<SpeciesRepository>(
          create: (_) => SpeciesRepository(database, powerSyncDatabase),
        ),
        ChangeNotifierProvider<ObservationRepository>(
          create: (_) =>
              ObservationRepository(powerSyncDatabase, attachmentUploadService),
        ),
      ],
      child: const KospiaApp(),
    ),
  );
}

class KospiaApp extends StatelessWidget {
  const KospiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kospia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
