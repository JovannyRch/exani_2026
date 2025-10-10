import 'package:examen_vial_edomex_app_2025/screens/home_screen.dart';
import 'package:examen_vial_edomex_app_2025/services/admob_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdMobService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Examen EdoMéx',
      home: HomeScreen(),
    );
  }
}
