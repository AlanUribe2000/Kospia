import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';

import 'backend_connector.dart';
import 'powersync_schema.dart';

Future<PowerSyncDatabase> openKospiaPowerSyncDatabase() async {
  final directory = await getApplicationSupportDirectory();
  final path = p.join(directory.path, 'kospia-powersync.db');
  final database = PowerSyncDatabase(schema: kospiaPowerSyncSchema, path: path);

  await database.initialize();
  return database;
}

Future<void> connectKospiaPowerSync(PowerSyncDatabase database) {
  return database.connect(connector: KospiaBackendConnector());
}
