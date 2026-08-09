import 'package:exani/services/purchase_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerScale;
  late Animation<double> _headerFade;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _headerScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listController.forward();
    });

    // Listen for purchase messages
    PurchaseService().onMessage = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    };
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    PurchaseService().onMessage = null;
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    SoundService().playTap();
    setState(() => _purchasing = true);
    await PurchaseService().buyPro();
    if (mounted) setState(() => _purchasing = false);
  }

  Future<void> _handleRestore() async {
    SoundService().playTap();
    await PurchaseService().restorePurchases();
  }

  Future<void> _handleManageSubscription() async {
    SoundService().playTap();
    await PurchaseService().openSubscriptionManagement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: PurchaseService().isPro,
          builder: (context, isPro, _) {
            return Column(
              children: [
                // ─── Header ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          SoundService().playTap();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),

                // ─── Content ────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Crown icon + title
                        FadeTransition(
                          opacity: _headerFade,
                          child: ScaleTransition(
                            scale: _headerScale,
                            child: Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFFA000),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFFD700,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 52,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  isPro ? '¡Ya eres Pro! ⭐' : 'Versión Pro',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isPro
                                      ? 'Disfruta todas las ventajas sin anuncios'
                                      : 'Desbloquea la experiencia completa por '
                                          '${PurchaseService().pricePerPeriodString}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Benefits list
                        _buildBenefitItem(
                          index: 0,
                          icon: Icons.block_rounded,
                          color: AppColors.red,
                          title: 'Sin anuncios',
                          subtitle:
                              'Estudia sin interrupciones ni distracciones',
                        ),
                        const SizedBox(height: 12),
                        _buildBenefitItem(
                          index: 1,
                          icon: Icons.quiz_rounded,
                          color: AppColors.primary,
                          title: 'Simulacro completo',
                          subtitle: 'Acceso ilimitado a exámenes de práctica',
                        ),
                        const SizedBox(height: 12),
                        _buildBenefitItem(
                          index: 2,
                          icon: Icons.insights_rounded,
                          color: AppColors.secondary,
                          title: 'Estadísticas avanzadas',
                          subtitle: 'Análisis detallado de tu progreso',
                        ),
                        const SizedBox(height: 12),
                        _buildBenefitItem(
                          index: 3,
                          icon: Icons.favorite_rounded,
                          color: AppColors.orange,
                          title: 'Cancela cuando quieras',
                          subtitle:
                              'Sin permanencia, gestionas todo desde la tienda',
                        ),

                        const SizedBox(height: 40),

                        // Already-pro badge (only inside scroll)
                        if (isPro) ...[
                          _buildProBadge(),
                          const SizedBox(height: 24),
                        ],

                        // Disclaimer
                        Text(
                          isPro
                              ? 'Tu suscripción se renueva automáticamente cada mes. '
                                  'Puedes cancelarla cuando quieras desde la tienda.'
                              : 'Suscripción mensual de ${PurchaseService().priceString} · '
                                  'Se renueva automáticamente · Cancela cuando quieras',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (isPro) ...[
                          _buildManageButton(),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                // ─── Pinned bottom: Purchase button ──────────
                if (!isPro) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPurchaseButton(),
                        const SizedBox(height: 12),
                        _buildRestoreButton(),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required int index,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final double t = (_listController.value - (index * 0.15)).clamp(
          0.0,
          1.0,
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle_rounded,
              color: color.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    final price = PurchaseService().pricePerPeriodString;
    return _PressableButton(
      onTap: _purchasing ? null : _handlePurchase,
      color: const Color(0xFFFFD700),
      darkColor: const Color(0xFFCC9E00),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_purchasing)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          else ...[
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Suscribirme · $price',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return GestureDetector(
      onTap: _handleRestore,
      child: const Text(
        'Restaurar suscripción',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildManageButton() {
    return GestureDetector(
      onTap: _handleManageSubscription,
      child: const Text(
        'Gestionar suscripción',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Text(
            'Suscripción Pro activa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Duolingo-style 3D Pressable Button ─────────────────────────────────────

class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color darkColor;

  const _PressableButton({
    required this.child,
    required this.onTap,
    required this.color,
    required this.darkColor,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        padding: EdgeInsets.only(bottom: _pressed ? 0 : 4),
        decoration: BoxDecoration(
          color: widget.darkColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
