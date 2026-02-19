import 'package:exani/screens/auth_gate.dart';
import 'package:exani/services/admob_service.dart';
import 'package:exani/services/notification_service.dart';
import 'package:exani/services/purchase_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/services/theme_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SupabaseService().initialize();
  await ThemeService().initialize();
  await AdMobService.initialize(); // TODO: Configurar AdMob ID real
  await SoundService().initialize();
  await NotificationService().initialize();
  await PurchaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mi App de Examen',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const AuthGate(),
        );
      },
    );
  }
}
