import 'package:flutter/material.dart';
import 'package:exani/screens/auth_screen.dart';
import 'package:exani/screens/exam_selection_screen.dart';
import 'package:exani/screens/onboarding_screen.dart';
import 'package:exani/screens/exani_home_screen.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget raíz que escucha el estado de autenticación y muestra
/// AuthScreen o el flujo de onboarding según corresponda.
///
/// Flujo completo:
///   No logueado → AuthScreen
///   Logueado + !onboarding_done → ExamSelectionScreen → OnboardingScreen → ExaniHomeScreen
///   Logueado + onboarding_done  → ExaniHomeScreen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _sb = SupabaseService();
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = _sb.authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Mientras espera el primer evento, revisar si ya hay sesión
        if (!snapshot.hasData) {
          if (_sb.isLoggedIn) {
            return _HomeRouter(userId: _sb.currentUser!.id);
          }
          return const _SplashLoading();
        }

        final session = snapshot.data!.session;

        if (session != null) {
          return _HomeRouter(userId: session.user.id);
        }

        return const AuthScreen();
      },
    );
  }
}

/// Router que decide qué pantalla mostrar según el estado de onboarding del usuario.
class _HomeRouter extends StatelessWidget {
  final String userId;

  const _HomeRouter({required this.userId});

  @override
  Widget build(BuildContext context) {
    final sb = SupabaseService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: sb.profiles.select().eq('id', userId).maybeSingle(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _SplashLoading();
        }

        final profile = snapshot.data;

        // Si no existe perfil o onboarding_done es false/null → flujo de onboarding
        if (profile == null || profile['onboarding_done'] != true) {
          return ExamSelectionScreen(
            onExamSelected: (examId) async {
              final examName = examId == 1 ? 'EXANI-II' : 'EXANI-I';

              // Navegar a OnboardingScreen
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder:
                      (_) => OnboardingScreen(
                        examId: examId,
                        examName: examName,
                        onComplete: ({
                          targetDate,
                          selectedModuleIds = const [],
                        }) async {
                          // Guardar datos de onboarding en Supabase
                          await sb.saveOnboardingData(
                            examId: examId,
                            examDate: targetDate,
                            moduleIds: selectedModuleIds,
                          );

                          // Navegar al dashboard principal
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (_) => ExaniHomeScreen(
                                      examId: examId.toString(),
                                      examName: examName,
                                      examDate: targetDate,
                                      moduleIds:
                                          selectedModuleIds
                                              .map((id) => id.toString())
                                              .toList(),
                                    ),
                              ),
                            );
                          }
                        },
                      ),
                ),
              );
            },
          );
        }

        // Usuario completó onboarding → dashboard principal con datos del perfil
        final examId = profile['exam_id'] ?? 1;
        final examName = examId == 1 ? 'EXANI-II' : 'EXANI-I';
        final examDateStr = profile['exam_date'];
        final DateTime? examDate =
            examDateStr != null ? DateTime.tryParse(examDateStr) : null;
        final moduleIds =
            (profile['modules_json'] as List<dynamic>?)
                ?.map((id) => id.toString())
                .toList() ??
            [];

        return ExaniHomeScreen(
          examId: examId.toString(),
          examName: examName,
          examDate: examDate,
          moduleIds: moduleIds,
        );
      },
    );
  }
}

/// Splash breve mientras se resuelve el estado de autenticación.
class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF58CC02))),
    );
  }
}
