import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../services/hybrid_ai_service.dart';
import '../../data/prompt_templates.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class AcademicHealthView extends StatefulWidget {
  const AcademicHealthView({super.key});

  @override
  State<AcademicHealthView> createState() => _AcademicHealthViewState();
}

class _AcademicHealthViewState extends State<AcademicHealthView> {
  Course? _selectedCourse;
  double _currentScore = 65;
  final TextEditingController _strugglesController = TextEditingController(
    text: 'Struggling with timed multi-variable regression problem sets and hypothesis testing edge cases.',
  );

  bool _isGenerating = false;
  String _recoveryPlan = '';
  StreamSubscription<String>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    _strugglesController.dispose();
    super.dispose();
  }

  void _generateRecoveryPlan() {
    final aiService = context.read<HybridAiService>();
    final courseCode = _selectedCourse?.code ?? 'AID601';

    setState(() {
      _isGenerating = true;
      _recoveryPlan = '';
    });

    final prompt = PromptTemplates.buildAcademicHealthPrompt(
      courseCode: courseCode,
      currentScore: _currentScore,
      weakAreas: _strugglesController.text,
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
              _recoveryPlan += chunk;
            });
          },
          onDone: () => setState(() => _isGenerating = false),
          onError: (e) {
            setState(() {
              _recoveryPlan += '\n\n*(Error: $e)*';
              _isGenerating = false;
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UniversityRepository>();
    final courses = repo.selectedCourses;
    if (_selectedCourse == null && courses.isNotEmpty) {
      _selectedCourse = courses.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassCard(
            backgroundColor: AppTheme.amberWarning.withValues(alpha: 0.08),
            borderColor: AppTheme.amberWarning.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.amberWarning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monitor_heart_rounded, color: AppTheme.amberWarning, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Health & Early-Warning Diagnostic',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flags performance dips before finals. AI analyzes quiz scores and self-reported obstacles to prescribe high-yield grade-recovery interventions.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Diagnostic Inputs
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Course Under Review:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                if (courses.isNotEmpty)
                  DropdownButtonFormField<Course>(
                    initialValue: _selectedCourse,
                    dropdownColor: AppTheme.cardSurface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.cardSurfaceLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: courses.map((c) {
                      return DropdownMenuItem(value: c, child: Text('${c.code} - ${c.name}'));
                    }).toList(),
                    onChanged: (c) => setState(() => _selectedCourse = c),
                  )
                else
                  const Text('No courses enrolled yet. Please enroll in electives first.', style: TextStyle(color: AppTheme.amberWarning)),
                const SizedBox(height: 16),

                // Midterm Score Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Standing / Midterm Score:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '${_currentScore.toInt()}% (${_currentScore >= 75 ? "Safe" : (_currentScore >= 60 ? "At-Risk (B- / C+)" : "Critical Danger")})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _currentScore >= 75 ? AppTheme.emeraldGreen : (_currentScore >= 60 ? AppTheme.amberWarning : AppTheme.roseDanger),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _currentScore,
                  min: 30,
                  max: 100,
                  divisions: 70,
                  activeColor: _currentScore >= 75 ? AppTheme.emeraldGreen : (_currentScore >= 60 ? AppTheme.amberWarning : AppTheme.roseDanger),
                  onChanged: (val) => setState(() => _currentScore = val),
                ),
                const SizedBox(height: 14),

                const Text('Specific Conceptual Blockers or Mistakes:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _strugglesController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardSurfaceLight,
                    hintText: 'What topics or question types did you lose marks on?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _generateRecoveryPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.amberWarning,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isGenerating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.healing_rounded, size: 18),
                  label: Text(_isGenerating ? 'Analyzing Trajectory...' : 'Generate 14-Day Grade Recovery Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Generated Plan
          if (_isGenerating || _recoveryPlan.isNotEmpty)
            GlassCard(
              borderColor: AppTheme.amberWarning.withValues(alpha: 0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_rounded, color: AppTheme.amberWarning, size: 20),
                      const SizedBox(width: 8),
                      const Text('Personalized Grade-Recovery Prescription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      if (_isGenerating)
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.amberWarning)),
                    ],
                  ),
                  const Divider(color: AppTheme.borderColor, height: 24),
                  GptMarkdown(
                    _recoveryPlan.isEmpty ? 'Calculating intervention milestones...' : _recoveryPlan,
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
