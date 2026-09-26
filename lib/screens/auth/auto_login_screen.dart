import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../data/student_personas.dart';
import '../../models/student_profile.dart';
import '../../services/university_repository.dart';
import '../main_navigation_shell.dart';

class AutoLoginScreen extends StatefulWidget {
  const AutoLoginScreen({super.key});

  @override
  State<AutoLoginScreen> createState() => _AutoLoginScreenState();
}

class _AutoLoginScreenState extends State<AutoLoginScreen> {
  bool _rememberAutoLogin = true;
  String? _authenticatingPersonaId;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberAutoLogin = prefs.getBool('remember_auto_login') ?? true;
      });
    } catch (_) {}
  }

  Future<void> _performAutoLogin(StudentProfile persona, {bool isAdvisor = false}) async {
    setState(() {
      _authenticatingPersonaId = persona.id;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_logged_in_persona', persona.id);
      await prefs.setBool('remember_auto_login', _rememberAutoLogin);
    } catch (_) {}

    // Simulated high-speed SSO verification
    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;
    final repo = context.read<UniversityRepository>();
    repo.switchStudentPersona(persona);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationShell(
          initialStudio: isAdvisor ? StudioMode.advisor : StudioMode.student,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryViolet, AppTheme.neonCyan],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryViolet.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, AppTheme.violetLight, AppTheme.neonCyan],
                            ).createShader(bounds),
                            child: const Text(
                              'UniPilot AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontSize: 32,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),
                          const Text(
                            'Academic & Career Operating System • BITSoM OneID™ SSO',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 0.2),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryViolet.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryViolet.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: AppTheme.violetLight, size: 14),
                        SizedBox(width: 8),
                        Text(
                          'Select Persona for 1-Click Instant Auto-Login',
                          style: TextStyle(color: AppTheme.violetLight, fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3 Student Persona Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 800;
                      return isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildStudentCard(StudentPersonas.demoPersonas[0], AppTheme.primaryViolet, Icons.person_rounded)),
                                const SizedBox(width: 18),
                                Expanded(child: _buildStudentCard(StudentPersonas.demoPersonas[1], AppTheme.neonCyan, Icons.psychology_rounded)),
                                const SizedBox(width: 18),
                                Expanded(child: _buildStudentCard(StudentPersonas.demoPersonas[2], AppTheme.emeraldGreen, Icons.insights_rounded)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildStudentCard(StudentPersonas.demoPersonas[0], AppTheme.primaryViolet, Icons.person_rounded),
                                const SizedBox(height: 16),
                                _buildStudentCard(StudentPersonas.demoPersonas[1], AppTheme.neonCyan, Icons.psychology_rounded),
                                const SizedBox(height: 16),
                                _buildStudentCard(StudentPersonas.demoPersonas[2], AppTheme.emeraldGreen, Icons.insights_rounded),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Faculty & Advisor One-Click Portal
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppTheme.amberWarning.withValues(alpha: 0.35),
                    backgroundColor: AppTheme.cardSurface.withValues(alpha: 0.7),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.amberWarning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: AppTheme.amberWarning, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Advisor & Faculty Control Tower',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Monitor cohort-wide elective demand forecasts, section fill-rates, and at-risk student academic triage.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _performAutoLogin(StudentPersonas.demoPersonas.first, isAdvisor: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.amberWarning,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                          label: const Text('Auto-Login as Advisor'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Remember Auto-Login Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _rememberAutoLogin,
                        activeColor: AppTheme.primaryViolet,
                        onChanged: (val) {
                          setState(() {
                            _rememberAutoLogin = val ?? true;
                          });
                        },
                      ),
                      const Text(
                        'Keep active demo session authenticated',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(StudentProfile persona, Color accentColor, IconData icon) {
    final isAuthenticating = _authenticatingPersonaId == persona.id;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: accentColor.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    Text(
                      persona.program,
                      style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Academic Snapshot Badges
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardSurfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Standing: Term ${persona.currentTerm}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('GPA: ${persona.currentGpa.toStringAsFixed(2)} / 4.0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(color: AppTheme.borderColor, height: 1),
                const SizedBox(height: 6),
                Text(
                  'Target: ${persona.careerAmbition}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transcripts: ${persona.completedCourseCodes.join(", ")}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Auto-Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAuthenticating ? null : () => _performAutoLogin(persona),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              icon: isAuthenticating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.flash_on_rounded, size: 18),
              label: Text(
                isAuthenticating ? 'Authenticating...' : 'Auto-Login as ${persona.name.split(" ").first}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
