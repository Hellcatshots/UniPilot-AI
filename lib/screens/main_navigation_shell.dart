import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/engine_status_chip.dart';
import '../widgets/api_settings_dialog.dart';
import 'student/student_dashboard.dart';
import 'advisor/advisor_dashboard.dart';

import 'auth/auto_login_screen.dart';

enum StudioMode { student, advisor }

class MainNavigationShell extends StatefulWidget {
  final StudioMode initialStudio;
  const MainNavigationShell({super.key, this.initialStudio = StudioMode.student});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late StudioMode _currentStudio;

  @override
  void initState() {
    super.initState();
    _currentStudio = widget.initialStudio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryViolet, AppTheme.neonCyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Text(
                  'Academic & Career Operating System',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 0.2),
                ),
              ],
            ),
            const SizedBox(width: 28),

            // Studio Selector Segmented Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  _buildStudioButton(
                    title: 'Student Degree Studio',
                    icon: Icons.school_rounded,
                    mode: StudioMode.student,
                  ),
                  const SizedBox(width: 4),
                  _buildStudioButton(
                    title: 'Advisor & Faculty Studio',
                    icon: Icons.account_balance_rounded,
                    mode: StudioMode.advisor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        actions: [
          const EngineStatusChip(),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Configure Hybrid AI Engine',
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ApiSettingsDialog(),
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Switch Persona / Auto-Login Portal',
            icon: const Icon(Icons.account_circle_outlined, color: AppTheme.neonCyan),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AutoLoginScreen()),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _currentStudio == StudioMode.student
            ? const StudentDashboard()
            : const AdvisorDashboard(),
      ),
    );
  }

  Widget _buildStudioButton({
    required String title,
    required IconData icon,
    required StudioMode mode,
  }) {
    final isSelected = _currentStudio == mode;

    return InkWell(
      onTap: () {
        if (_currentStudio != mode) {
          setState(() {
            _currentStudio = mode;
          });
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryViolet : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
