import 'package:flutter/material.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/duo_button.dart';

/// Pantalla 2 del MVP: Onboarding post-selección de examen.
/// - Elegir fecha objetivo (opcional)
/// - Elegir módulos disciplinares (solo EXANI-II)
class OnboardingScreen extends StatefulWidget {
  final int examId;
  final String examName; // 'EXANI-II' o 'EXANI-I'

  /// Callback al completar onboarding.
  /// Recibe fecha objetivo y módulos seleccionados.
  final Future<void> Function({
    DateTime? targetDate,
    List<int> selectedModuleIds,
  })
  onComplete;

  const OnboardingScreen({
    super.key,
    required this.examId,
    required this.examName,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime? _targetDate;
  final Set<int> _selectedModuleIds = {};
  bool _isLoading = false;

  bool get _isExaniII => widget.examId == 1;
  int get _totalPages => _isExaniII ? 2 : 1; // EXANI-I no tiene step de módulos

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentPage++);
    } else {
      // Mostrar loading mientras guarda y navega
      setState(() => _isLoading = true);
      try {
        await widget.onComplete(
          targetDate: _targetDate,
          selectedModuleIds: _selectedModuleIds.toList(),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con progreso
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  // Back
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                        setState(() => _currentPage--);
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(width: 24),
                  const SizedBox(width: 16),
                  // Progress bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        minHeight: 6,
                        backgroundColor: AppColors.progressTrack,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _DatePage(
                    examName: widget.examName,
                    selectedDate: _targetDate,
                    onDateSelected:
                        (date) => setState(() => _targetDate = date),
                  ),
                  if (_isExaniII)
                    _ModulesPage(
                      selectedIds: _selectedModuleIds,
                      onToggle: (id) {
                        setState(() {
                          if (_selectedModuleIds.contains(id)) {
                            _selectedModuleIds.remove(id);
                          } else if (_selectedModuleIds.length < 2) {
                            _selectedModuleIds.add(id);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),

            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  if (_isLoading)
                    const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    DuoButton(
                      text:
                          _currentPage == _totalPages - 1
                              ? 'Comenzar'
                              : 'Siguiente',
                      color: AppColors.primary,
                      onPressed: _nextPage,
                    ),
                  if (_currentPage == 0 && !_isLoading) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _nextPage,
                      child: Text(
                        'Omitir por ahora',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Fecha objetivo ─────────────────────────────────────────────────

class _DatePage extends StatelessWidget {
  final String examName;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const _DatePage({
    required this.examName,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.orange,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¿Cuándo presentas tu $examName?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te ayudamos a planear tu estudio según tu fecha',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // Date picker button
          GestureDetector(
            onTap: () async {
              SoundService().playTap();
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    selectedDate ??
                    DateTime.now().add(const Duration(days: 30)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: AppColors.surface,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) onDateSelected(picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      selectedDate != null
                          ? AppColors.primary
                          : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    color:
                        selectedDate != null
                            ? AppColors.primary
                            : AppColors.textLight,
                    size: 24,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : 'Seleccionar fecha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                    ),
                  ),
                  const Spacer(),
                  if (selectedDate != null)
                    _DaysChip(
                      days: selectedDate!.difference(DateTime.now()).inDays,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

class _DaysChip extends StatelessWidget {
  final int days;
  const _DaysChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            days < 30
                ? AppColors.orange.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$days días',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: days < 30 ? AppColors.orange : AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Step 2: Módulos disciplinares (solo EXANI-II) ──────────────────────────

/// Módulos disciplinares EXANI-II con su ID de sección en el seed
class _ModuleOption {
  final int sectionId;
  final String name;
  final IconData icon;

  const _ModuleOption(this.sectionId, this.name, this.icon);
}

const _modules = [
  _ModuleOption(4, 'Física', Icons.rocket_launch_rounded),
  _ModuleOption(5, 'Química', Icons.science_rounded),
  _ModuleOption(6, 'Prob. y estadística', Icons.bar_chart_rounded),
  _ModuleOption(7, 'Administración', Icons.business_rounded),
  // TODO: agregar más módulos cuando existan en el seed
];

class _ModulesPage extends StatelessWidget {
  final Set<int> selectedIds;
  final ValueChanged<int> onToggle;

  const _ModulesPage({required this.selectedIds, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: AppColors.secondary,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Elige 2 módulos disciplinares',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Son los que tu universidad asignó. Si no sabes, elige los que más se acerquen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedIds.length}/2 seleccionados',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color:
                  selectedIds.length == 2
                      ? AppColors.primary
                      : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: _modules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final mod = _modules[index];
                final isSelected = selectedIds.contains(mod.sectionId);
                final isDisabled = !isSelected && selectedIds.length >= 2;

                return GestureDetector(
                  onTap:
                      isDisabled
                          ? null
                          : () {
                            SoundService().playTap();
                            onToggle(mod.sectionId);
                          },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary.withValues(alpha: 0.06)
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : isDisabled
                                ? AppColors.cardBorder.withValues(alpha: 0.5)
                                : AppColors.cardBorder,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isDisabled
                                    ? AppColors.textLight
                                    : AppColors.secondary)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            mod.icon,
                            color:
                                isDisabled
                                    ? AppColors.textLight
                                    : AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            mod.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDisabled
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : isDisabled
                                  ? AppColors.textLight.withValues(alpha: 0.5)
                                  : AppColors.textLight,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
