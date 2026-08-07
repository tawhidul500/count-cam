final class AppConfig {
  const AppConfig._();

  static const String appName = 'ClearScan';
  static const String tagline = 'Smart Scanner. Better Documents.';
  static const String versionName = '0.1.0';
  static const String releaseLabel = 'UI prototype';
  static const String environment = String.fromEnvironment(
    'CLEARSCAN_ENV',
    defaultValue: 'development',
  );

  static const bool cloudSyncEnabled = false;
  static const bool premiumEnabled = false;
}
