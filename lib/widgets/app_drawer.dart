import 'package:flutter/material.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/services/theme_service.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/screens/progress_screen.dart';
import 'package:exani/screens/pro_screen.dart';

/// Drawer lateral de la app con:
/// - Info del usuario
/// - Selector de examen activo
/// - Gestión de exámenes (agregar/quitar)
/// - Toggle de tema
/// - Opciones (Progreso, Leaderboard, Pro)
/// - Cerrar sesión
class AppDrawer extends StatefulWidget {
  final Function(int examId)? onExamChanged;

  const AppDrawer({super.key, this.onExamChanged});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'Estudiante';
  String _userEmail = '';
  int? _activeExamId;
  List<Map<String, dynamic>> _userExams = [];
  List<Map<String, dynamic>> _allExams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = SupabaseService().currentUser;
      final profile = await SupabaseService().getMyProfile();
      final activeExamId = await SupabaseService().getActiveExamId();
      final userExams = await SupabaseService().getUserExams();

      // Get all available exams
      final allExamsData = await SupabaseService().exams
          .select()
          .eq('is_active', true)
          .order('id');

      if (mounted) {
        setState(() {
          _userName = profile?['display_name'] ?? 'Estudiante';
          _userEmail = user?.email ?? '';
          _activeExamId = activeExamId;
          _userExams = userExams;
          _allExams = List<Map<String, dynamic>>.from(allExamsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _switchExam(int examId) async {
    try {
      await SupabaseService().switchActiveExam(examId);
      setState(() => _activeExamId = examId);
      widget.onExamChanged?.call(examId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Examen cambiado correctamente'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar examen: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _addExam(int examId) async {
    try {
      await SupabaseService().addExamToUser(examId);
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Examen agregado a tu preparación'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar examen: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeExam(int examId) async {
    // Confirm deletion
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Remover examen?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Se eliminará este examen de tu preparación. Tu progreso se mantendrá guardado.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Remover',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await SupabaseService().removeExamFromUser(examId);
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Examen removido'),
            backgroundColor: AppColors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al remover examen: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header con info de usuario
            _buildUserHeader(),

            const Divider(height: 1),

            // Exámenes
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExamsSection(),
                            const Divider(height: 32),
                            _buildOptionsSection(),
                          ],
                        ),
                      ),
            ),

            const Divider(height: 1),

            // Logout
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Mis Exámenes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Lista de exámenes del usuario
        if (_userExams.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No tienes exámenes en preparación',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...(_userExams.map((exam) {
            final examId = exam['id'] as int;
            final examName = exam['name'] as String;
            final examCode = exam['code'] as String;
            final isActive = examId == _activeExamId;

            return _ExamTile(
              examName: examName,
              examCode: examCode,
              isActive: isActive,
              onTap: isActive ? null : () => _switchExam(examId),
              onRemove:
                  _userExams.length > 1 ? () => _removeExam(examId) : null,
            );
          })),

        // Botón para agregar más exámenes
        if (_userExams.length < _allExams.length) ...[
          const SizedBox(height: 8),
          _buildAddExamButton(),
        ],
      ],
    );
  }

  Widget _buildAddExamButton() {
    // Find exams not yet added
    final addedIds = _userExams.map((e) => e['id'] as int).toSet();
    final availableExams =
        _allExams.where((e) => !addedIds.contains(e['id'])).toList();

    if (availableExams.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () async {
          SoundService().playTap();

          // Show dialog to select exam
          final selectedExam = await showDialog<Map<String, dynamic>>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Agregar Examen',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        availableExams.map((exam) {
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              exam['name'] as String,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              exam['description'] as String? ?? '',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, exam),
                          );
                        }).toList(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
          );

          if (selectedExam != null) {
            await _addExam(selectedExam['id'] as int);
          }
        },
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Agregar otro examen'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Opciones',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Theme Toggle
        _DrawerTile(
          icon:
              ThemeService().isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
          title: 'Tema ${ThemeService().isDark ? "Claro" : "Oscuro"}',
          trailing: Switch(
            value: ThemeService().isDark,
            onChanged: (value) {
              SoundService().playTap();
              ThemeService().toggleTheme();
              setState(() {});
            },
            activeColor: AppColors.primary,
          ),
        ),

        // Progress
        _DrawerTile(
          icon: Icons.show_chart_rounded,
          title: 'Mi Progreso',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProgressScreen()),
            );
          },
        ),

        // Leaderboard
        _DrawerTile(
          icon: Icons.leaderboard_rounded,
          title: 'Tabla de Posiciones',
          onTap: () {
            Navigator.pop(context);
            // Se necesitará acceso al examId - por ahora omitimos examId o usamos default
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const LeaderboardScreen(examId: '1')),
            // );
          },
        ),

        // Pro Version
        _DrawerTile(
          icon: Icons.workspace_premium_rounded,
          iconColor: AppColors.orange,
          title: 'Versión Pro',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () async {
          SoundService().playTap();

          final confirm = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    '¿Cerrar sesión?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Tu progreso se mantendrá guardado.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                  ],
                ),
          );

          if (confirm == true) {
            await SupabaseService().signOut();
          }
        },
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Cerrar Sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}

// ─── Exam Tile ──────────────────────────────────────────────────────────────

class _ExamTile extends StatelessWidget {
  final String examName;
  final String examCode;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _ExamTile({
    required this.examName,
    required this.examCode,
    required this.isActive,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.cardBorder,
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap:
            onTap != null
                ? () {
                  SoundService().playTap();
                  onTap?.call();
                }
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          examCode == 'exani_ii'
              ? Icons.account_balance_rounded
              : Icons.menu_book_rounded,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          examName,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle:
            isActive
                ? Text(
                  'Activo ahora',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
                : null,
        trailing:
            onRemove != null
                ? IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.textLight),
                  onPressed: () {
                    SoundService().playTap();
                    onRemove?.call();
                  },
                )
                : isActive
                ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
                : null,
      ),
    );
  }
}

// ─── Drawer Tile ────────────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _DrawerTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap:
          onTap != null
              ? () {
                SoundService().playTap();
                onTap?.call();
              }
              : null,
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right_rounded, color: AppColors.textLight)
              : null),
    );
  }
}
