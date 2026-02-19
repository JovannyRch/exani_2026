import 'package:flutter/material.dart';
import 'package:exani/screens/auth_screen.dart';
import 'package:exani/screens/exam_selection_screen.dart';
import 'package:exani/screens/exani_home_screen.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget raíz que escucha el estado de autenticación y muestra
/// AuthScreen o el flujo de onboarding según corresponda.
///
/// Flujo simplificado:
///   No logueado → AuthScreen
///   Logueado + !onboarding_done → ExamSelectionScreen → ExaniHomeScreen
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
              try {
                // Guardar solo el examen seleccionado, sin fecha ni módulos (simplificado)
                await sb.saveOnboardingData(
                  examId: examId,
                  examDate: null, // Omitido temporalmente
                  moduleIds: [], // Omitido temporalmente
                );

                // El StreamBuilder detectará el cambio en onboarding_done
                // y navegará automáticamente a ExaniHomeScreen
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al guardar: $e'),
                      backgroundColor: const Color(0xFFFF4B4B),
                    ),
                  );
                }
              }
            },
          );
        }

        // Usuario completó onboarding → dashboard principal con datos del perfil
        final activeExamId = profile['active_exam_id'] as int? ?? 1;
        final examDateStr = profile['exam_date'];
        final DateTime? examDate =
            examDateStr != null ? DateTime.tryParse(examDateStr) : null;
        final moduleIds =
            (profile['modules_json'] as List<dynamic>?)
                ?.map((id) => id.toString())
                .toList() ??
            [];

        // Get exam name from database
        return FutureBuilder<Map<String, dynamic>?>(
          future: sb.exams.select().eq('id', activeExamId).maybeSingle(),
          builder: (context, examSnapshot) {
            if (!examSnapshot.hasData) {
              return const _SplashLoading();
            }

            final exam = examSnapshot.data;
            final examName = exam?['name'] as String? ?? 'EXANI-II';

            return ExaniHomeScreen(
              examId: activeExamId,
              examName: examName,
              examDate: examDate,
              moduleIds: moduleIds,
            );
          },
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
