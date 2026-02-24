import 'package:exani/models/option.dart';
import 'package:exani/services/admob_service.dart';
import 'package:exani/services/database_service.dart';
import 'package:exani/services/purchase_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/content_image.dart';
import 'package:exani/widgets/duo_button.dart';
import 'package:exani/widgets/latex_text.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Data class to hold each question + the options shown + user's answer
class ReviewItem {
  final Question question;
  final List<Option> options;
  final int? selectedOptionId;

  ReviewItem({
    required this.question,
    required this.options,
    this.selectedOptionId,
  });

  bool get isCorrect => selectedOptionId == question.correctOptionId;
  bool get wasAnswered => selectedOptionId != null;
}

class ReviewScreen extends StatefulWidget {
  final List<ReviewItem> items;
  final int totalCorrect;

  const ReviewScreen({
    super.key,
    required this.items,
    required this.totalCorrect,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Set<int> _favoriteIds = {};
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadFavorites();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() async {
    // Skip interstitial for Pro users
    if (PurchaseService().isProUser) return;
    _interstitialAd = await AdMobService.createInterstitialAd();
  }

  Future<void> _loadFavorites() async {
    final ids = await DatabaseService().getFavoriteIds();
    if (mounted) setState(() => _favoriteIds = ids.toSet());
  }

  Future<void> _toggleFavorite(int questionId) async {
    SoundService().playTap();
    final isNowFav = await DatabaseService().toggleFavorite(questionId);
    if (mounted) {
      setState(() {
        if (isNowFav) {
          _favoriteIds.add(questionId);
        } else {
          _favoriteIds.remove(questionId);
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.items.length;
    final correctCount = widget.totalCorrect;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(correctCount, totalQuestions),

            // ── Question List ───────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return _ReviewCard(
                    item: widget.items[index],
                    index: index,
                    animation: _animController,
                    isFavorite: _favoriteIds.contains(
                      widget.items[index].question.id,
                    ),
                    onToggleFavorite:
                        () => _toggleFavorite(widget.items[index].question.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Button ────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: DuoButton(
          text: 'Volver al inicio',
          color: AppColors.primary,
          icon: Icons.home_rounded,
          onPressed: () {
            // Show interstitial before going home
            if (_interstitialAd != null) {
              AdMobService.showInterstitialAd(_interstitialAd);
              // Wait a bit before navigating (ad will show)
              final nav = Navigator.of(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  nav.popUntil((route) => route.isFirst);
                }
              });
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int correct, int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Back + Title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.progressTrack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Revisión de Respuestas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Score summary chips
          Row(
            children: [
              _ScoreChip(
                icon: Icons.check_circle_rounded,
                label: '$correct correctas',
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _ScoreChip(
                icon: Icons.cancel_rounded,
                label: '${total - correct} incorrectas',
                color: AppColors.red,
              ),
              const SizedBox(width: 10),
              _ScoreChip(
                icon: Icons.quiz_rounded,
                label: '$total total',
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCORE CHIP
// ═══════════════════════════════════════════════════════════════════════════════

class _ScoreChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ScoreChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REVIEW CARD (per question)
// ═══════════════════════════════════════════════════════════════════════════════

class _ReviewCard extends StatefulWidget {
  final ReviewItem item;
  final int index;
  final AnimationController animation;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ReviewCard({
    required this.item,
    required this.index,
    required this.animation,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isCorrect = item.isCorrect;
    final wasAnswered = item.wasAnswered;

    final Color statusColor =
        !wasAnswered
            ? AppColors.orange
            : isCorrect
            ? AppColors.primary
            : AppColors.red;

    final IconData statusIcon =
        !wasAnswered
            ? Icons.remove_circle_rounded
            : isCorrect
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    final String statusText =
        !wasAnswered
            ? 'Sin responder'
            : isCorrect
            ? '¡Correcto!'
            : 'Incorrecto';

    // Staggered delay
    final delay = (widget.index * 0.06).clamp(0.0, 0.5);
    final curvedAnim = CurvedAnimation(
      parent: widget.animation,
      curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: curvedAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - curvedAnim.value)),
          child: Opacity(
            opacity: curvedAnim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Question header ──────────────────────────────────────
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: [
                    // Number badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Question text
                    Expanded(
                      child: LatexText(
                        item.question.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        maxLines: _expanded ? null : 2,
                        overflow: _expanded ? null : TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Status icon
                    Icon(statusIcon, color: statusColor, size: 26),

                    const SizedBox(width: 2),

                    // Bookmark
                    GestureDetector(
                      onTap: widget.onToggleFavorite,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          widget.isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          key: ValueKey(widget.isFavorite),
                          color:
                              widget.isFavorite
                                  ? AppColors.orange
                                  : AppColors.textLight,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    // Expand chevron
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.textLight,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Status label ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ),

            // ── Expanded details ─────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildDetails(item, statusColor),
              crossFadeState:
                  _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(ReviewItem item, Color statusColor) {
    final correctOption = item.question.options.firstWhere(
      (o) => o.id == item.question.correctOptionId,
    );

    Option? selectedOption;
    if (item.wasAnswered) {
      selectedOption = item.options.firstWhere(
        (o) => o.id == item.selectedOptionId,
        orElse: () => correctOption,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: AppColors.progressTrack,
            margin: const EdgeInsets.only(bottom: 14),
          ),

          // Options list
          ...item.options.map((opt) {
            final isCorrectOpt = opt.id == item.question.correctOptionId;
            final isSelectedOpt = opt.id == item.selectedOptionId;

            Color optBg;
            Color optBorder;
            Color optText;
            IconData? optIcon;

            if (isCorrectOpt) {
              optBg = AppColors.primary.withValues(alpha: 0.1);
              optBorder = AppColors.primary;
              optText = AppColors.darken(AppColors.primary, 0.15);
              optIcon = Icons.check_circle_rounded;
            } else if (isSelectedOpt && !isCorrectOpt) {
              optBg = AppColors.red.withValues(alpha: 0.1);
              optBorder = AppColors.red;
              optText = AppColors.darken(AppColors.red, 0.15);
              optIcon = Icons.cancel_rounded;
            } else {
              optBg = Colors.grey.shade50;
              optBorder = Colors.grey.shade200;
              optText = AppColors.textSecondary;
              optIcon = null;
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: optBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: optBorder, width: 1.5),
              ),
              child: Row(
                children: [
                  if (optIcon != null) ...[
                    Icon(
                      optIcon,
                      size: 20,
                      color: isCorrectOpt ? AppColors.primary : AppColors.red,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: OptionContent(
                      text: opt.text.replaceAll('[br]', '\n'),
                      imagePath: opt.imagePath,
                      imageHeight: 60,
                      textStyle: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            (isCorrectOpt || isSelectedOpt)
                                ? FontWeight.w600
                                : FontWeight.normal,
                        color: optText,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (isCorrectOpt)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Correcta',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

          // User answer summary if wrong
          if (item.wasAnswered && !item.isCorrect && selectedOption != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.red,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Tu respuesta: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: selectedOption.text.replaceAll('[br]', ' '),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Explanation
          if (item.question.explanation != null &&
              item.question.explanation!.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explicación',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LatexText(
                          item.question.explanation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darken(AppColors.secondary, 0.25),
                            height: 1.5,
                          ),
                        ),
                        // Imágenes de la explicación
                        if (item.question.hasExplanationImages) ...[
                          const SizedBox(height: 10),
                          ContentImageGallery(
                            images: item.question.explanationImages,
                            imageHeight: 120,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
