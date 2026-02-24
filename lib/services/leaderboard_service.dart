/// ─── Leaderboard Service ────────────────────────────────────────────────────
/// Servicio singleton para obtener y gestionar el ranking semanal.
/// Usa ValueNotifier para integración con la UI existente.
/// Conectado a Supabase RPC (get_weekly_leaderboard, get_my_leaderboard_position).
library;

import 'package:flutter/foundation.dart';
import 'package:exani/models/leaderboard.dart';
import 'package:exani/services/supabase_service.dart';

class LeaderboardService {
  // ─── Singleton ──────────────────────────────────────────────────────────
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  final _sb = SupabaseService();

  // ─── Estado observable ──────────────────────────────────────────────────

  final ValueNotifier<LeaderboardState> state = ValueNotifier(
    LeaderboardState(weekStart: _currentWeekStart()),
  );

  // ─── API pública ────────────────────────────────────────────────────────

  /// Carga el leaderboard de la semana actual para un examen.
  Future<void> loadLeaderboard({
    required int examId,
    DateTime? weekStart,
  }) async {
    final ws = weekStart ?? _currentWeekStart();
    final wsStr = ws.toIso8601String().substring(0, 10);

    state.value = LeaderboardState(weekStart: ws, isLoading: true);

    try {
      final currentUserId = _sb.isLoggedIn ? _sb.userId : null;

      // Obtener top 50
      final entriesRaw = await _sb.rpc(
        'get_weekly_leaderboard',
        params: {'p_exam_id': examId, 'p_week_start': wsStr},
      );

      final entries =
          (entriesRaw as List<dynamic>? ?? [])
              .map<LeaderboardEntry>(
                (row) => LeaderboardEntry.fromJson(
                  row as Map<String, dynamic>,
                  currentUserId: currentUserId,
                ),
              )
              .toList();

      // Obtener mi posición
      MyLeaderboardPosition? myPos;
      if (currentUserId != null) {
        try {
          final posRaw = await _sb.rpc(
            'get_my_leaderboard_position',
            params: {
              'p_user_id': currentUserId,
              'p_exam_id': examId,
              'p_week_start': wsStr,
            },
          );
          if (posRaw != null && posRaw is List && posRaw.isNotEmpty) {
            myPos = MyLeaderboardPosition.fromJson(
              posRaw.first as Map<String, dynamic>,
            );
          } else if (posRaw != null && posRaw is Map<String, dynamic>) {
            myPos = MyLeaderboardPosition.fromJson(posRaw);
          }
        } catch (e) {
          debugPrint('Leaderboard: Sin posición del usuario ($e)');
        }
      }

      state.value = LeaderboardState(
        weekStart: ws,
        entries: entries,
        myPosition: myPos,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
      state.value = LeaderboardState(
        weekStart: ws,
        error: 'Error al cargar ranking: $e',
      );
    }
  }

  /// Refresca el leaderboard (trigger recálculo + recarga).
  Future<void> refresh({required int examId}) async {
    try {
      // Recalcular en servidor
      await _sb.rpc('compute_weekly_leaderboard');
      await loadLeaderboard(examId: examId);
    } catch (e) {
      debugPrint('Error refreshing leaderboard: $e');
      // Intentar cargar aunque falle el recálculo
      await loadLeaderboard(examId: examId);
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  /// Lunes de la semana actual (ISO: lunes = día 1)
  static DateTime _currentWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Texto legible de la semana (ej: "10 – 16 Feb 2026")
  static String weekLabel(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} – ${weekEnd.day} ${months[weekStart.month]} ${weekStart.year}';
    }
    return '${weekStart.day} ${months[weekStart.month]} – ${weekEnd.day} ${months[weekEnd.month]} ${weekEnd.year}';
  }
}
