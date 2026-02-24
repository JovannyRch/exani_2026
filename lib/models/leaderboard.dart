/// ─── Leaderboard Models ─────────────────────────────────────────────────────
/// Modelos de datos para el ranking semanal.
library;

/// Una entrada en el leaderboard semanal.
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String displayName;
  final double score;
  final double accuracyPct;
  final int avgTimeMs;
  final int totalQuestions;
  final int sessionsCount;
  final int totalPoints;

  /// True si es el usuario actual
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.score,
    required this.accuracyPct,
    required this.avgTimeMs,
    required this.totalQuestions,
    required this.sessionsCount,
    required this.totalPoints,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final uid = json['user_id'] as String;
    return LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      userId: uid,
      displayName: json['display_name'] as String? ?? 'Anónimo',
      score: (json['score'] as num).toDouble(),
      accuracyPct: (json['accuracy_pct'] as num).toDouble(),
      avgTimeMs: (json['avg_time_ms'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      sessionsCount: (json['sessions_count'] as num).toInt(),
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      isCurrentUser: uid == currentUserId,
    );
  }

  /// Tiempo promedio formateado (ej: "12.5s")
  String get avgTimeFormatted => '${(avgTimeMs / 1000).toStringAsFixed(1)}s';

  /// Score formateado (ej: "78.5")
  String get scoreFormatted => score.toStringAsFixed(1);

  /// Precisión formateada (ej: "85.0%")
  String get accuracyFormatted => '${accuracyPct.toStringAsFixed(1)}%';

  /// Emoji de medalla según rank
  String get medal {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}

/// Posición del usuario actual en el ranking.
class MyLeaderboardPosition {
  final int rank;
  final double score;
  final double accuracyPct;
  final int totalQuestions;
  final int sessionsCount;
  final int totalParticipants;
  final int totalPoints;

  const MyLeaderboardPosition({
    required this.rank,
    required this.score,
    required this.accuracyPct,
    required this.totalQuestions,
    required this.sessionsCount,
    required this.totalParticipants,
    required this.totalPoints,
  });

  factory MyLeaderboardPosition.fromJson(Map<String, dynamic> json) {
    return MyLeaderboardPosition(
      rank: (json['rank'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      accuracyPct: (json['accuracy_pct'] as num).toDouble(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      sessionsCount: (json['sessions_count'] as num).toInt(),
      totalParticipants: (json['total_participants'] as num).toInt(),
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
    );
  }

  /// True si está en top 10
  bool get isTopTen => rank <= 10;

  /// Percentil (ej: si rank=5 de 100 → top 5%)
  double get percentile =>
      totalParticipants > 0 ? (rank / totalParticipants) * 100 : 100;

  /// Texto amigable del percentil (ej: "Top 5%")
  String get percentileText => 'Top ${percentile.ceil()}%';
}

/// Estado del leaderboard para la UI.
class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final MyLeaderboardPosition? myPosition;
  final bool isLoading;
  final String? error;
  final DateTime weekStart;

  const LeaderboardState({
    this.entries = const [],
    this.myPosition,
    this.isLoading = false,
    this.error,
    required this.weekStart,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    MyLeaderboardPosition? myPosition,
    bool? isLoading,
    String? error,
  }) => LeaderboardState(
    entries: entries ?? this.entries,
    myPosition: myPosition ?? this.myPosition,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    weekStart: weekStart,
  );

  /// True si el usuario no tiene posición (no cumple mínimo de 20 preguntas)
  bool get userNotRanked => myPosition == null && !isLoading;
}
