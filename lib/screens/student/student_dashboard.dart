import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../data/student_personas.dart';
import '../../theme/app_theme.dart';
import 'career_compass_view.dart';
import 'timetable_balancer_view.dart';
import 'syllabus_copilot_view.dart';
import 'campus_navigator_view.dart';
import 'academic_health_view.dart';
import 'unipilot_chat_view.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Career Compass', 'icon': Icons.explore_rounded},
    {'title': 'Timetable & Conflicts', 'icon': Icons.calendar_today_rounded},
    {'title': 'Syllabus Copilot', 'icon': Icons.auto_stories_rounded},
    {'title': 'Campus Navigator', 'icon': Icons.hub_rounded},
    {'title': 'Academic Health', 'icon': Icons.monitor_heart_rounded},
    {'title': 'Ask UniPilot', 'icon': Icons.chat_bubble_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UniversityRepository>();
    final activeStudent = repo.activeStudent;
    final conflicts = repo.currentConflicts;

    return Column(
      children: [
        // Persona Switcher Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1626),
            border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.3),
                    child: Text(
                      activeStudent.name[0],
                      style: const TextStyle(color: AppTheme.violetLight, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activeStudent.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${activeStudent.program} • Term ${activeStudent.currentTerm}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),

              // Switch Persona Preset for instant Judge Demo
              const Text('Switch Demo Persona: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              ...StudentPersonas.demoPersonas.map((p) {
                final isCurrent = p.id == activeStudent.id;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => repo.switchStudentPersona(p),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.primaryViolet : AppTheme.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isCurrent ? AppTheme.primaryViolet : AppTheme.borderColor),
                      ),
                      child: Text(
                        p.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),

        // Sub-Tab Navigation Bar
        Container(
          color: AppTheme.darkBg,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.neonCyan,
            indicatorWeight: 3,
            labelColor: AppTheme.neonCyan,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: _tabs.map((tab) {
              final isTimetable = tab['title'] == 'Timetable & Conflicts';
              final hasClash = isTimetable && conflicts.isNotEmpty;

              return Tab(
                child: Row(
                  children: [
                    Icon(tab['icon'] as IconData, size: 16),
                    const SizedBox(width: 8),
                    Text(tab['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if (hasClash) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.roseDanger,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${conflicts.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              CareerCompassView(),
              TimetableBalancerView(),
              SyllabusCopilotView(),
              CampusNavigatorView(),
              AcademicHealthView(),
              UnipilotChatView(),
            ],
          ),
        ),
      ],
    );
  }
}
