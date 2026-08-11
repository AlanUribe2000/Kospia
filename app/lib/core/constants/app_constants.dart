class AppConstants {
  AppConstants._();

  static const String appName = 'Kospia';
  static const String appSubtitle = 'Flora Patagonica';
  static const String databaseName = 'kospia_local.db';
  static const int databaseVersion = 5;
  // Partes de la planta para fotos
  static const List<String> plantParts = [
    'general',
    'hoja',
    'espinas',
    'flor',
    'fruto',
  ];
  static const String partGeneral = 'general';
  static const String partHoja = 'hoja';
  static const String partEspinas = 'espinas';
  static const String partFlor = 'flor';
  static const String partFruto = 'fruto';
  // Tamaño de Kospi en toda la app
  static const double kospiImageHeight = 180.0;
  static const String testUserId = 'test-user-001';
  static const String testUserName = 'test';
  static const String syncPending = 'pending';
  static const String syncSynced = 'synced';
  static const String syncConflict = 'conflict';
}
