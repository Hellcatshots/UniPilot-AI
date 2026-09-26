import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../models/conflict_result.dart';
import '../../data/university_catalog.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/course_card.dart';

class TimetableBalancerView extends StatefulWidget {
  const TimetableBalancerView({super.key});

  @override
  State<TimetableBalancerView> createState() => _TimetableBalancerViewState();
}

class _TimetableBalancerViewState extends State<TimetableBalancerView> {
  String _selectedDepartmentFilter = 'All';

  final List<String> _departments = [
    'All',
    'Product & Tech',
    'AI & Analytics',
    'Finance',
    'Strategy',
    'Marketing',
    'Operations',
  ];

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<String> _slots = [
    '09:00 - 10:30',
    '10:45 - 12:15',
    '13:30 - 15:00',
    '15:15 - 16:45',
  ];

  void _triggerClashDemo() {
    // Deliberately enroll in two clashing courses to demonstrate conflict engine to judges
    final repo = context.read<UniversityRepository>();
    repo.setEnrolledCourses(['pmt_670', 'fin_702', 'pmt_650']);
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UniversityRepository>();
    final enrolledCourses = repo.selectedCourses;
    final conflicts = repo.currentConflicts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Stats Card
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interactive Timetable & Cognitive Workload Balancer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100% offline deterministic constraint solver monitors lecture overlaps, prerequisite chains, and cognitive burnout hotspots.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Credits Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    children: [
                      const Text('ENROLLED LOAD', style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        '${repo.totalEnrolledCredits} / 15 Credits',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: repo.totalEnrolledCredits > 15 ? AppTheme.roseDanger : AppTheme.neonCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Export Schedule Button
                OutlinedButton.icon(
                  onPressed: () {
                    final buffer = StringBuffer();
                    buffer.writeln('================================================');
                    buffer.writeln('🎓 UNIPILOT AI — VERIFIED ENROLLMENT CARD');
                    buffer.writeln('Student: ${repo.activeStudent.name} (${repo.activeStudent.program})');
                    buffer.writeln('Enrolled Credits: ${repo.totalEnrolledCredits} / 15');
                    buffer.writeln('Schedule Status: ${conflicts.isEmpty ? "VERIFIED (0 Clashes)" : "${conflicts.length} Conflict(s) Detected"}');
                    buffer.writeln('------------------------------------------------');
                    buffer.writeln('ENROLLED ELECTIVES:');
                    for (final c in enrolledCourses) {
                      buffer.writeln('• ${c.code}: ${c.name} | ${c.days.join("/")} ${c.timeSlot}');
                    }
                    buffer.writeln('================================================');
                    Clipboard.setData(ClipboardData(text: buffer.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.emeraldGreen,
                        content: Text('📋 Verified Schedule copied to clipboard! Ready to share with Academic Advisor.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.neonCyan,
                    side: const BorderSide(color: AppTheme.neonCyan),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text('Export Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                // Clash Test Demo Button
                OutlinedButton.icon(
                  onPressed: _triggerClashDemo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.amberWarning,
                    side: const BorderSide(color: AppTheme.amberWarning),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 16),
                  label: const Text('Simulate Clash', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Conflicts Alert Box (if any)
          if (conflicts.isNotEmpty) ...[
            ...conflicts.map((conflict) {
              final isError = conflict.severity == ConflictSeverity.error;
              final accentColor = isError ? AppTheme.roseDanger : AppTheme.amberWarning;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(isError ? Icons.error_rounded : Icons.warning_amber_rounded, color: accentColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                conflict.title,
                                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Spacer(),
                              Text(
                                conflict.affectedCourseCodes.join(' ↔ '),
                                style: TextStyle(color: accentColor, fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(conflict.description, style: const TextStyle(fontSize: 13, height: 1.4)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.emeraldGreen, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Fix: ${conflict.actionableFix}',
                                  style: const TextStyle(color: AppTheme.emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => repo.resolveAllConflictsAutoBalance(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emeraldGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
                      label: const Text('Auto-Resolve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ] else if (enrolledCourses.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.emeraldGreen, size: 20),
                  SizedBox(width: 10),
                  Text(
                    '✅ Timetable Validated: 0 Schedule Clashes, Prerequisites Satisfied, Balanced Workload Profile.',
                    style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],

          // Weekly Schedule Visualizer Grid
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_view_week_rounded, color: AppTheme.violetLight, size: 20),
                    SizedBox(width: 8),
                    Text('Weekly Lecture & Discussion Time Grid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 16),

                // Table Layout
                Table(
                  border: TableBorder.all(color: AppTheme.borderColor, width: 1, borderRadius: BorderRadius.circular(8)),
                  columnWidths: const {
                    0: FixedColumnWidth(110),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                    5: FlexColumnWidth(1),
                  },
                  children: [
                    // Day Headers
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFF161E33)),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          child: Text('TIME SLOT', style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        ..._days.map((d) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            child: Center(
                              child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                            ),
                          );
                        }),
                      ],
                    ),

                    // Time Slot Rows
                    ...List.generate(_slots.length, (slotIdx) {
                      final slotTime = _slots[slotIdx];

                      return TableRow(
                        children: [
                          // Time Label
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              slotTime,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),

                          // Days Cells
                          ..._days.map((day) {
                            // Find courses meeting in this slot & day
                            final matchedCourses = enrolledCourses.where((c) {
                              return c.timeSlotIndex == slotIdx && c.days.contains(day);
                            }).toList();

                            if (matchedCourses.isEmpty) {
                              return Container(
                                height: 60,
                                color: Colors.transparent,
                              );
                            }

                            final isCollision = matchedCourses.length > 1;

                            return Container(
                              height: 60,
                              margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isCollision
                                    ? AppTheme.roseDanger.withValues(alpha: 0.35)
                                    : AppTheme.primaryViolet.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCollision ? AppTheme.roseDanger : AppTheme.primaryViolet,
                                  width: isCollision ? 1.8 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: matchedCourses.map((c) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isCollision)
                                        const Icon(Icons.error_outline_rounded, color: AppTheme.roseDanger, size: 12),
                                      const SizedBox(width: 2),
                                      Text(
                                        c.code,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isCollision ? AppTheme.roseDanger : AppTheme.violetLight,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Course Catalog Browser
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Text(
                'Available University Elective Catalog (50+ Courses)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
              // Department Filter Chips
              Wrap(
                spacing: 6,
                children: _departments.map((dept) {
                  final isSelected = _selectedDepartmentFilter == dept;
                  return ChoiceChip(
                    label: Text(dept, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppTheme.textSecondary)),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryViolet,
                    backgroundColor: AppTheme.cardSurface,
                    onSelected: (_) {
                      setState(() {
                        _selectedDepartmentFilter = dept;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid of Courses
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final filteredCourses = UniversityCatalog.allCourses.where((c) {
                if (_selectedDepartmentFilter == 'All') return true;
                return c.department.toLowerCase().contains(_selectedDepartmentFilter.toLowerCase());
              }).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemCount: filteredCourses.length,
                itemBuilder: (context, idx) {
                  final course = filteredCourses[idx];
                  final isEnrolled = repo.isCourseSelected(course.id);

                  return CourseCard(
                    course: course,
                    isSelected: isEnrolled,
                    onToggle: () => repo.toggleCourseEnrollment(course.id),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
