import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/species_repository.dart';
import 'data/repositories/observation_repository.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ocultar barras del sistema. Solo aparecen al deslizar desde el borde.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<SpeciesRepository>(create: (_) => SpeciesRepository(database)),
        ChangeNotifierProvider<ObservationRepository>(
          create: (_) => ObservationRepository(database),
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
    // Eliminar padding del sistema para que SafeArea no reserve espacio negro
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero),
      child: MaterialApp(
        title: 'Kospia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
