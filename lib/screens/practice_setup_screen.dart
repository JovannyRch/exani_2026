import 'package:flutter/material.dart';
import 'package:exani/services/sound_service.dart';
import 'package:exani/services/supabase_service.dart';
import 'package:exani/theme/app_theme.dart';
import 'package:exani/widgets/duo_button.dart';
import 'package:exani/widgets/app_loader.dart';
import 'package:exani/models/option.dart';
import 'package:exani/screens/guide_screen.dart';

/// Pantalla 5 MVP — Seleccionar sección → área → habilidad para práctica.
/// Navegación drill-down con 3D cards.
class PracticeSetupScreen extends StatefulWidget {
  final String examId;

  const PracticeSetupScreen({super.key, required this.examId});

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Data from Supabase
  List<_Section> _sections = [];
  _Section? _selectedSection;
  _Area? _selectedArea;
  bool _isLoading = true;
  String? _error;

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
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Parse examId from widget parameter
      final examId = int.tryParse(widget.examId) ?? 1;

      final sectionsData = await SupabaseService().getSectionsHierarchy(examId);

      final sections = <_Section>[];

      for (final sectionData in sectionsData) {
        // Determine icon and color based on section name
        final sectionName = sectionData['name'] as String;
        final IconData icon;
        final Color color;

        if (sectionName.toLowerCase().contains('matemá')) {
          icon = Icons.calculate_rounded;
          color = AppColors.secondary;
        } else if (sectionName.toLowerCase().contains('lectora')) {
          icon = Icons.auto_stories_rounded;
          color = AppColors.orange;
        } else if (sectionName.toLowerCase().contains('redacción')) {
          icon = Icons.spellcheck_rounded;
          color = AppColors.primary;
        } else if (sectionName.toLowerCase().contains('química')) {
          icon = Icons.science_rounded;
          color = AppColors.primary;
        } else if (sectionName.toLowerCase().contains('física')) {
          icon = Icons.rocket;
          color = AppColors.redDark;
        } else {
          icon = Icons.psychology_rounded;
          color = AppColors.purple;
        }

        final areasData = sectionData['areas'] as List<dynamic>;
        final areas = <_Area>[];

        for (final areaData in areasData) {
          final areaId = areaData['id'] as int;
          final skillsData = areaData['skills'] as List<dynamic>;

          // Get question count for this area
          final questionCount = await SupabaseService().countQuestionsForArea(
            areaId,
          );

          areas.add(
            _Area(
              id: areaId.toString(),
              name: areaData['name'] as String,
              skills:
                  skillsData
                      .map(
                        (s) => _Skill(
                          id: s['id'] as int,
                          name: s['name'] as String,
                        ),
                      )
                      .toList(),
              questionCount: questionCount,
            ),
          );
        }

        sections.add(
          _Section(
            id: (sectionData['id'] as int).toString(),
            name: sectionName,
            icon: icon,
            color: color,
            areas: areas,
          ),
        );
      }

      setState(() {
        _sections = sections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las secciones: $e';
        _isLoading = false;
      });
      debugPrint('Error loading sections: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_selectedArea != null) {
      setState(() => _selectedArea = null);
    } else if (_selectedSection != null) {
      setState(() => _selectedSection = null);
    } else {
      Navigator.pop(context);
    }
  }

  String get _title {
    if (_selectedArea != null) return _selectedArea!.name;
    if (_selectedSection != null) return _selectedSection!.name;
    return 'Práctica por tema';
  }

  /// Filtra preguntas por skill/área/sección desde Supabase
  Future<List<Question>> _filterQuestions({
    int? sectionId,
    int? areaId,
    int? skillId,
    int limit = 20,
  }) async {
    try {
      List<Map<String, dynamic>> questionsData;

      // Query según el nivel más específico disponible
      if (skillId != null) {
        questionsData = await SupabaseService().getQuestionsBySkill(
          skillId: skillId,
          limit: limit,
        );
      } else if (areaId != null) {
        final areaIdInt = int.tryParse(areaId.toString());
        if (areaIdInt == null) {
          debugPrint('Invalid areaId: $areaId');
          return [];
        }
        questionsData = await SupabaseService().getQuestionsByArea(
          areaId: areaIdInt,
          limit: limit,
        );
      } else if (sectionId != null) {
        final sectionIdInt = int.tryParse(sectionId.toString());
        if (sectionIdInt == null) {
          debugPrint('Invalid sectionId: $sectionId');
          return [];
        }
        questionsData = await SupabaseService().getQuestionsBySection(
          sectionId: sectionIdInt,
          limit: limit,
        );
      } else {
        // No filter specified - return empty to show proper error
        debugPrint('No filter specified');
        return [];
      }

      // Convertir datos de Supabase a objetos Question
      final questionsList =
          questionsData.map((q) => Question.fromSupabase(q)).toList();

      // Shuffle para variedad
      questionsList.shuffle();

      return questionsList;
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      // Return empty list on error - user will see proper error message
      return [];
    }
  }

  Future<void> _startPractice({
    String? areaName,
    String? skillName,
    int? skillId,
  }) async {
    // Show loading indicator
    AppLoading.show(
      context,
      message: 'Preparando preguntas...',
      dismissible: false,
    );

    try {
      // Get area id from selected area
      final areaId = _selectedArea?.id;
      final sectionId = _selectedSection?.id;

      final practiceQuestions = await _filterQuestions(
        sectionId: sectionId != null ? int.tryParse(sectionId) : null,
        areaId: areaId != null ? int.tryParse(areaId) : null,
        skillId: skillId,
        limit: 20,
      );

      // Close loading dialog
      if (mounted) AppLoading.hide(context);

      if (practiceQuestions.isEmpty) {
        // Mostrar mensaje si no hay preguntas
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No hay preguntas disponibles para este tema',
              ),
              backgroundColor: AppColors.red,
            ),
          );
        }
        return;
      }

      SoundService().playTap();

      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (_, __, ___) => GuideScreen(
                  allQuestions: practiceQuestions,
                  title: skillName ?? areaName ?? _selectedSection?.name,
                ),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) AppLoading.hide(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar preguntas: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
      debugPrint('Error starting practice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // Breadcrumb hint
                    if (_selectedSection != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedSection!.color.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedArea != null ? 'Habilidad' : 'Área',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedSection!.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoader(message: 'Cargando secciones...');
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DuoButton(
                text: 'Reintentar',
                color: AppColors.primary,
                icon: Icons.refresh_rounded,
                onPressed: _loadSections,
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedArea != null) {
      return _buildSkillList(_selectedArea!);
    }
    if (_selectedSection != null) {
      return _buildAreaList(_selectedSection!);
    }
    return _buildSectionList();
  }

  // ─── Level 1: Secciones ──────────────────────────────────────────────────

  Widget _buildSectionList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: _sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = _sections[index];
        final totalQuestions = section.areas.fold<int>(
          0,
          (sum, a) => sum + a.questionCount,
        );
        return _Pressable3DCard(
          onTap: () => setState(() => _selectedSection = section),
          darkColor: AppColors.darken(section.color, 0.18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(section.icon, color: section.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${section.areas.length} áreas · $totalQuestions reactivos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Level 2: Áreas ──────────────────────────────────────────────────────

  Widget _buildAreaList(_Section section) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: section.areas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final area = section.areas[index];
        return _Pressable3DCard(
          onTap: () => setState(() => _selectedArea = area),
          darkColor: AppColors.darken(section.color, 0.18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: section.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: section.color,
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
                      area.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${area.skills.length} habilidades · ${area.questionCount} reactivos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Level 3: Habilidades ────────────────────────────────────────────────

  Widget _buildSkillList(_Area area) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Practicar toda el área
        DuoButton(
          text: 'Practicar toda el área',
          color: _selectedSection!.color,
          icon: Icons.play_arrow_rounded,
          onPressed: () => _startPractice(areaName: area.name),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'O elige una habilidad específica',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        ...area.skills.map((skill) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Pressable3DCard(
              darkColor: AppColors.darken(_selectedSection!.color, 0.18),
              onTap:
                  () => _startPractice(
                    areaName: area.name,
                    skillName: skill.name,
                    skillId: skill.id,
                  ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _selectedSection!.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: _selectedSection!.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      skill.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.play_circle_outline_rounded,
                    color: _selectedSection!.color,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────

class _Section {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<_Area> areas;

  const _Section({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.areas,
  });
}

class _Area {
  final String id;
  final String name;
  final List<_Skill> skills;
  final int questionCount;

  const _Area({
    required this.id,
    required this.name,
    required this.skills,
    required this.questionCount,
  });
}

class _Skill {
  final int id;
  final String name;

  const _Skill({required this.id, required this.name});
}

// ─── Reusable 3D pressable card ──────────────────────────────────────────────

class _Pressable3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color darkColor;

  const _Pressable3DCard({
    required this.child,
    required this.onTap,
    required this.darkColor,
  });

  @override
  State<_Pressable3DCard> createState() => _Pressable3DCardState();
}

class _Pressable3DCardState extends State<_Pressable3DCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        SoundService().playTap();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _isPressed ? 3 : 0),
        padding: EdgeInsets.only(bottom: _isPressed ? 0 : 3),
        decoration: BoxDecoration(
          color: widget.darkColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder, width: 2),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
