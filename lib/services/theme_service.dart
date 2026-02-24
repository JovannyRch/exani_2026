import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _key = 'theme_mode';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  ThemeMode get currentMode => themeMode.value;

  bool get isDark {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  String get modeLabel {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (stored == 'system') {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serializeThemeMode(mode));
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  String _serializeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Mixin para forzar rebuild inmediato cuando cambia el tema.
/// Útil en widgets que usan AppColors (sin depender de Theme.of).
mixin ThemeModeRebuildMixin<T extends StatefulWidget> on State<T> {
  void _onThemeModeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ThemeService().themeMode.addListener(_onThemeModeChanged);
  }

  @override
  void dispose() {
    ThemeService().themeMode.removeListener(_onThemeModeChanged);
    super.dispose();
  }
}
