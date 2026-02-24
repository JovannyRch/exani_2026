import 'package:flutter/material.dart';
import 'package:exani/models/leaderboard.dart';
import 'package:exani/services/leaderboard_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';

/// Pantalla 7 MVP — Ranking semanal.
/// Top 50, posición del usuario, percentil, medallas top 3.
class LeaderboardScreen extends StatefulWidget {
  final String examId;

  const LeaderboardScreen({super.key, required this.examId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final _service = LeaderboardService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
    _service.loadLeaderboard(examId: int.tryParse(widget.examId) ?? 1);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Ranking semanal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        SoundService().playTap();
                        _service.refresh(
                          examId: int.tryParse(widget.examId) ?? 1,
                        );
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Week label
              ValueListenableBuilder<LeaderboardState>(
                valueListenable: _service.state,
                builder: (context, state, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          LeaderboardService.weekLabel(state.weekStart),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Content
              Expanded(
                child: ValueListenableBuilder<LeaderboardState>(
                  valueListenable: _service.state,
                  builder: (context, state, _) {
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (state.error != null) {
                      return _buildError(state.error!);
                    }
                    if (state.entries.isEmpty) {
                      return _buildEmpty();
                    }
                    return _buildList(state);
                  },
                ),
              ),

              // My position footer
              ValueListenableBuilder<LeaderboardState>(
                valueListenable: _service.state,
                builder: (context, state, _) {
                  if (state.myPosition == null || state.userNotRanked) {
                    return const SizedBox.shrink();
                  }
                  return _buildMyPosition(state.myPosition!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error al cargar el ranking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty ─────────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: AppColors.textLight,
              size: 56,
            ),
            const SizedBox(height: 14),
            Text(
              'Aún no hay ranking esta semana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Completa sesiones de práctica para aparecer en el ranking semanal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── List ──────────────────────────────────────────────────────────────────

  Widget _buildList(LeaderboardState state) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      itemCount: state.entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = state.entries[index];
        return _LeaderboardRow(entry: entry);
      },
    );
  }

  // ─── My Position Footer ────────────────────────────────────────────────────

  Widget _buildMyPosition(MyLeaderboardPosition pos) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${pos.rank}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu posición',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  pos.percentileText,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${pos.totalPoints} pts',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Leaderboard Row ─────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardRow({required this.entry});

  Color get _rankColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;
    final isMe = entry.isCurrentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:
            isMe
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isMe
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child:
                isTop3
                    ? Text(
                      entry.medal,
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    )
                    : Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _rankColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
          ),
          const SizedBox(width: 12),

          // Avatar placeholder
          CircleAvatar(
            radius: 18,
            backgroundColor: _rankColor.withValues(alpha: 0.15),
            child: Text(
              entry.displayName.isNotEmpty
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(fontWeight: FontWeight.bold, color: _rankColor),
            ),
          ),
          const SizedBox(width: 12),

          // Name + accuracy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isMe ? AppColors.primary : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.accuracyPct.round()}% · ${entry.totalQuestions} reactivos',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Points
          Text(
            '${entry.totalPoints}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTop3 ? _rankColor : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
