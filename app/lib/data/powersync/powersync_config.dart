/// Runtime configuration for the Kospia backend and PowerSync service.
class PowerSyncConfig {
  static const backendUrl = String.fromEnvironment(
    'KOSPIA_BACKEND_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const powerSyncUrl = String.fromEnvironment(
    'KOSPIA_POWERSYNC_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const tokenPath = String.fromEnvironment(
    'KOSPIA_TOKEN_PATH',
    defaultValue: '/auth/powersync-token',
  );
}
