import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../services/hybrid_ai_service.dart';
import '../../data/prompt_templates.dart';
import '../../data/university_catalog.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class CareerCompassView extends StatefulWidget {
  const CareerCompassView({super.key});

  @override
  State<CareerCompassView> createState() => _CareerCompassViewState();
}

class _CareerCompassViewState extends State<CareerCompassView> {
  late TextEditingController _careerController;
  bool _isGenerating = false;
  String _generatedOutput = '';
  StreamSubscription<String>? _streamSub;

  final List<String> _popularCareers = [
    'FinTech Product Manager',
    'GenAI & Applied ML Systems Architect',
    'Strategy & Management Consultant',
    'Venture Capital & PE Analyst',
    'Growth & Marketing Analytics Lead',
  ];

  @override
  void initState() {
    super.initState();
    final repo = UniversityRepository();
    _careerController = TextEditingController(text: repo.activeStudent.careerAmbition);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _careerController.dispose();
    super.dispose();
  }

  void _triggerAnalysis() {
    final repo = context.read<UniversityRepository>();
    final aiService = context.read<HybridAiService>();
    final ambition = _careerController.text.trim();
    if (ambition.isEmpty) return;

    repo.updateCareerAmbition(ambition);

    setState(() {
      _isGenerating = true;
      _generatedOutput = '';
    });

    final catalogSummary = UniversityCatalog.allCourses.take(24).map((c) {
      return '- ${c.code}: ${c.name} (${c.department}, Term ${c.term}, ${c.days.join('/')} ${c.timeSlot}, Skills: ${c.industrySkills.take(3).join(', ')})';
    }).join('\n');

    final prompt = PromptTemplates.buildCareerCompassPrompt(
      studentName: repo.activeStudent.name,
      careerAmbition: ambition,
      completedCourses: repo.activeStudent.completedCourseCodes,
      availableCoursesSummary: catalogSummary,
    );

    _streamSub?.cancel();
    _streamSub = aiService
        .generateStream(
          systemPrompt: PromptTemplates.systemBasePrompt,
          userPrompt: prompt,
          maxTokens: 1800,
        )
        .listen(
          (chunk) {
            setState(() {
              _generatedOutput += chunk;
            });
          },
          onDone: () {
            setState(() {
              _isGenerating = false;
            });
          },
          onError: (e) {
            setState(() {
              _generatedOutput += '\n\n*(Error generating plan: $e)*';
              _isGenerating = false;
            });
          },
        );
  }

  void _autoEnrollForCareer() {
    final repo = context.read<UniversityRepository>();
    final ambition = _careerController.text.trim();
    final student = repo.activeStudent;

    // 1. DYNAMIC AI EXTRACTION: Extract courses actually recommended in the LLM's generated output
    final detectedCourseIds = <String>[];
    if (_generatedOutput.isNotEmpty) {
      for (final course in UniversityCatalog.allCourses) {
        final pattern = RegExp('\\b${RegExp.escape(course.code)}\\b', caseSensitive: false);
        if (pattern.hasMatch(_generatedOutput)) {
          if (!detectedCourseIds.contains(course.id)) {
            detectedCourseIds.add(course.id);
          }
        }
      }
    }

    // 2. Select top 3 non-clashing electives from AI recommendations
    if (detectedCourseIds.length >= 2) {
      final validBundle = <String>[];
      for (final id in detectedCourseIds) {
        final candidate = UniversityCatalog.getCourseById(id);
        if (candidate == null) continue;

        bool clashes = false;
        for (final acceptedId in validBundle) {
          final accepted = UniversityCatalog.getCourseById(acceptedId);
          if (accepted != null && accepted.term == candidate.term) {
            final sharedDays = candidate.days.where((d) => accepted.days.contains(d)).toList();
            if (sharedDays.isNotEmpty && candidate.timeSlotIndex == accepted.timeSlotIndex) {
              clashes = true;
              break;
            }
          }
        }

        if (!clashes) {
          validBundle.add(id);
          if (validBundle.length == 3) break;
        }
      }

      if (validBundle.isNotEmpty) {
        repo.setEnrolledCourses(validBundle);
        final courseCodes = validBundle.map((id) => UniversityCatalog.getCourseById(id)?.code ?? id).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.emeraldGreen,
            content: Text('✅ Enrolled in $courseCodes (Dynamically extracted from AI output)!'),
          ),
        );
        return;
      }
    }

    // 3. DYNAMIC SEMANTIC MATCHING: Rank catalog courses by relevance to user's custom ambition
    final queryTokens = ambition.toLowerCase().split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
    final scoredCourses = UniversityCatalog.allCourses.map((c) {
      int score = 0;
      final searchableText = '${c.name} ${c.department} ${c.industrySkills.join(" ")} ${c.syllabusSummary}'.toLowerCase();
      for (final token in queryTokens) {
        if (searchableText.contains(token)) score += 3;
        if (c.name.toLowerCase().contains(token)) score += 5;
      }
      final meetsPrereqs = c.prerequisites.every((p) => student.completedCourseCodes.contains(p));
      if (meetsPrereqs) score += 2;
      return MapEntry(c, score);
    }).toList();

    scoredCourses.sort((a, b) => b.value.compareTo(a.value));

    final selected = <String>[];
    for (final entry in scoredCourses) {
      final candidate = entry.key;
      bool clashes = false;
      for (final enrolledId in selected) {
        final existing = UniversityCatalog.getCourseById(enrolledId);
        if (existing != null && existing.term == candidate.term) {
          final sharedDays = candidate.days.where((d) => existing.days.contains(d)).toList();
          if (sharedDays.isNotEmpty && candidate.timeSlotIndex == existing.timeSlotIndex) {
            clashes = true;
            break;
          }
        }
      }
      if (!clashes) {
        selected.add(candidate.id);
        if (selected.length == 3) break;
      }
    }

    repo.setEnrolledCourses(selected);
    final codes = selected.map((id) => UniversityCatalog.getCourseById(id)?.code ?? id).join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.emeraldGreen,
        content: Text('✅ Dynamically matched & enrolled: $codes for "$ambition"!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UniversityRepository>();
    final student = repo.activeStudent;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassCard(
            backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.1),
            borderColor: AppTheme.primaryViolet.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryViolet.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.explore_rounded, color: AppTheme.violetLight, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Career-to-Elective Compass',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Maps 50+ university electives to high-stakes job market competencies. AI identifies skill gaps and curates an optimal schedule without prerequisite or timetable clashes.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Career Target Input & Quick Presets
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '1. What is your Target Post-Graduation Career Goal?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _careerController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. FinTech Product Manager, Quant Risk Analyst, ESG Consultant...',
                          filled: true,
                          fillColor: AppTheme.cardSurfaceLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.stars_rounded, color: AppTheme.amberWarning),
                        ),
                        onSubmitted: (_) => _triggerAnalysis(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _triggerAnalysis,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(_isGenerating ? 'Synthesizing...' : 'Generate Career Trajectory'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Popular Presets
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularCareers.map((c) {
                    final isSelected = _careerController.text == c;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _careerController.text = c;
                        });
                        _triggerAnalysis();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryViolet.withValues(alpha: 0.3) : AppTheme.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryViolet : AppTheme.borderColor,
                          ),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.violetLight : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Active Student Transcript Context
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded, color: AppTheme.neonCyan, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Student Transcript: ${student.name} • Completed: ${student.completedCourseCodes.join(', ')} • Current GPA: ${student.currentGpa.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live AI Output
          if (_isGenerating || _generatedOutput.isNotEmpty)
            GlassCard(
              borderColor: AppTheme.primaryViolet.withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology_rounded, color: AppTheme.neonCyan, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Trajectory Analysis & Elective Recommendation',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          if (_isGenerating)
                            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonCyan)),
                        ],
                      ),
                      if (!_isGenerating && _generatedOutput.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _autoEnrollForCareer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.emeraldGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                          label: const Text('1-Click Enroll Recommended Bundle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  GptMarkdown(
                    _generatedOutput.isEmpty ? 'Synthesizing career curriculum mapping...' : _generatedOutput,
                    style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
