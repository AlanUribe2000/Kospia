import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/repositories/species_repository.dart';
import 'data/repositories/observation_repository.dart';
import 'features/home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<SpeciesRepository>(create: (_) => SpeciesRepository(database)),
        Provider<ObservationRepository>(
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
    return MaterialApp(
      title: 'Kospia - Flora Patagonica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
