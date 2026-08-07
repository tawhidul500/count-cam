import 'package:clearscan/app/configuration/app_config.dart';
import 'package:clearscan/app/theme/app_theme.dart';
import 'package:clearscan/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';

class ClearScanApp extends StatelessWidget {
  const ClearScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
