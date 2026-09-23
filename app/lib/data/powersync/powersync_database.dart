import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';

import 'powersync_schema.dart';

Future<PowerSyncDatabase> openKospiaPowerSyncDatabase(String userId) async {
  final uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  if (!uuidPattern.hasMatch(userId)) {
    throw ArgumentError.value(
      userId,
      'userId',
      'Debe ser un UUID interno válido.',
    );
  }

  final directory = await getApplicationSupportDirectory();
  final path = p.join(directory.path, 'kospia-powersync-$userId.db');
  final database = PowerSyncDatabase(schema: kospiaPowerSyncSchema, path: path);

  await database.initialize();
  return database;
}
