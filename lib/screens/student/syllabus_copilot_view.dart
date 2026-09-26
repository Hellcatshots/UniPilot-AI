import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../services/hybrid_ai_service.dart';
import '../../data/prompt_templates.dart';
import '../../data/university_catalog.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class SyllabusCopilotView extends StatefulWidget {
  final Course? initialCourse;
  const SyllabusCopilotView({super.key, this.initialCourse});

  @override
  State<SyllabusCopilotView> createState() => _SyllabusCopilotViewState();
}

class _SyllabusCopilotViewState extends State<SyllabusCopilotView> {
  late Course _selectedCourse;
  bool _isGenerating = false;
  String _generatedPlan = '';
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    final repo = UniversityRepository();
    final enrolled = repo.selectedCourses;
    _selectedCourse = widget.initialCourse ??
        (enrolled.isNotEmpty ? enrolled.first : UniversityCatalog.allCourses.first);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _generateStudyPlan() {
    final aiService = context.read<HybridAiService>();

    setState(() {
      _isGenerating = true;
      _generatedPlan = '';
    });

    final prompt = PromptTemplates.buildSyllabusStudyPlanPrompt(
      courseCode: _selectedCourse.code,
      courseName: _selectedCourse.name,
      syllabus: _selectedCourse.syllabusSummary,
      assessmentFormat: _selectedCourse.assessmentFormat,
    );

    _sub?.cancel();
    _sub = aiService
        .generateStream(
          systemPrompt: PromptTemplates.systemBasePrompt,
          userPrompt: prompt,
          maxTokens: 1800,
        )
        .listen(
          (chunk) {
            setState(() {
              _generatedPlan += chunk;
            });
          },
          onDone: () => setState(() => _isGenerating = false),
          onError: (e) {
            setState(() {
              _generatedPlan += '\n\n*(Error: $e)*';
              _isGenerating = false;
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassCard(
            backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.08),
            borderColor: AppTheme.neonCyan.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: AppTheme.neonCyan, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Syllabus-to-Milestone Learning Copilot',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transforms passive syllabus outlines into structured 6-week active learning schedules, reading focus notes, and high-scoring grade exam strategies.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Course Picker & Generate Button
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Enrolled or Catalog Elective:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Course>(
                            value: _selectedCourse,
                            isExpanded: true,
                            dropdownColor: AppTheme.cardSurface,
                            items: UniversityCatalog.allCourses.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text('${c.code}: ${c.name} (Prof. ${c.professorName})', style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (newCourse) {
                              if (newCourse != null) {
                                setState(() {
                                  _selectedCourse = newCourse;
                                  _generatedPlan = '';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateStudyPlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isGenerating
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.flash_on_rounded, size: 18),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate 6-Week Study Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Course Meta Overview
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurfaceLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Syllabus Focus: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMuted)),
                          Expanded(child: Text(_selectedCourse.syllabusSummary, style: const TextStyle(fontSize: 12))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Grading Breakdown: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMuted)),
                          Expanded(child: Text(_selectedCourse.assessmentFormat, style: const TextStyle(fontSize: 12, color: AppTheme.amberWarning))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Output Plan
          if (_isGenerating || _generatedPlan.isNotEmpty)
            GlassCard(
              borderColor: AppTheme.neonCyan.withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppTheme.emeraldGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Active Study Plan for ${_selectedCourse.code}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      if (_isGenerating)
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonCyan)),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  GptMarkdown(
                    _generatedPlan.isEmpty ? 'Formulating 6-week study milestones...' : _generatedPlan,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
