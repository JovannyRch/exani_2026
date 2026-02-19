import 'package:flutter/material.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/duo_button.dart';

/// Pantalla 1 del MVP: Selección de examen (EXANI-II / EXANI-I).
/// Se muestra al primer uso o cuando el usuario quiere cambiar de examen.
class ExamSelectionScreen extends StatefulWidget {
  /// Callback cuando el usuario selecciona un examen.
  /// Recibe el examId (1 = EXANI-II, 2 = EXANI-I).
  final void Function(int examId) onExamSelected;

  const ExamSelectionScreen({super.key, required this.onExamSelected});

  @override
  State<ExamSelectionScreen> createState() => _ExamSelectionScreenState();
}

class _ExamSelectionScreenState extends State<ExamSelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _card1Controller;
  late final AnimationController _card2Controller;
  late final Animation<Offset> _card1Slide;
  late final Animation<Offset> _card2Slide;

  int? _selectedExamId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _card1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _card2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _card1Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _card1Controller, curve: Curves.easeOutCubic),
    );

    _card2Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _card2Controller, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _card1Controller.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _card2Controller.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _card1Controller.dispose();
    _card2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo / Icono
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  '¿Para cuál examen\nte preparas?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Podrás cambiar después en ajustes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 36),

                // EXANI-II Card
                SlideTransition(
                  position: _card1Slide,
                  child: FadeTransition(
                    opacity: _card1Controller,
                    child: _ExamCard(
                      examId: 1,
                      title: 'EXANI-II',
                      subtitle: 'Ingreso a universidad',
                      description: '3 áreas transversales · 2 módulos · Inglés',
                      icon: Icons.account_balance_rounded,
                      color: AppColors.primary,
                      reactivos: '168 reactivos',
                      isSelected: _selectedExamId == 1,
                      onTap:
                          _isLoading
                              ? null
                              : () {
                                SoundService().playTap();
                                setState(() => _selectedExamId = 1);
                              },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // EXANI-I Card
                SlideTransition(
                  position: _card2Slide,
                  child: FadeTransition(
                    opacity: _card2Controller,
                    child: _ExamCard(
                      examId: 2,
                      title: 'EXANI-I',
                      subtitle: 'Ingreso a preparatoria',
                      description: '4 áreas · Inglés diagnóstico',
                      icon: Icons.menu_book_rounded,
                      color: AppColors.secondary,
                      reactivos: '112 reactivos',
                      isSelected: _selectedExamId == 2,
                      onTap:
                          _isLoading
                              ? null
                              : () {
                                SoundService().playTap();
                                setState(() => _selectedExamId = 2);
                              },
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // CTA
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                    : DuoButton(
                      text: 'Continuar',
                      color: AppColors.primary,
                      onPressed:
                          _selectedExamId != null
                              ? () async {
                                setState(() => _isLoading = true);
                                try {
                                  widget.onExamSelected(_selectedExamId!);
                                  // El callback guardará y el AuthGate navegará automáticamente
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              }
                              : null,
                    ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Exam Card ──────────────────────────────────────────────────────────────

class _ExamCard extends StatefulWidget {
  final int examId;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String reactivos;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ExamCard({
    required this.examId,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.reactivos,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isSelected ? widget.color : AppColors.cardBorder;
    final bgColor =
        widget.isSelected
            ? widget.color.withValues(alpha: 0.06)
            : AppColors.surface;

    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp:
          isEnabled
              ? (_) {
                setState(() => _isPressed = false);
                widget.onTap?.call();
              }
              : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.only(top: _isPressed ? 2 : 0),
          padding: EdgeInsets.only(bottom: _isPressed ? 0 : 2),
          decoration: BoxDecoration(
            color: AppColors.darken(widget.color, 0.18),
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 28),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Check / Reactivos
                Column(
                  children: [
                    if (widget.isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: widget.color,
                        size: 26,
                      )
                    else
                      Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: AppColors.textLight,
                        size: 26,
                      ),
                    const SizedBox(height: 6),
                    Text(
                      widget.reactivos,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
