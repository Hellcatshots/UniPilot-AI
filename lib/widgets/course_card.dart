import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onSyllabusTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.isSelected,
    required this.onToggle,
    this.onSyllabusTap,
  });

  Color _getWorkloadColor(int level) {
    if (level <= 2) return AppTheme.emeraldGreen;
    if (level <= 3) return AppTheme.neonCyan;
    if (level <= 4) return AppTheme.amberWarning;
    return AppTheme.roseDanger;
  }

  @override
  Widget build(BuildContext context) {
    final workloadColor = _getWorkloadColor(course.workloadLevel);

    return GlassCard(
      borderColor: isSelected ? AppTheme.primaryViolet : AppTheme.borderColor,
      backgroundColor: isSelected ? AppTheme.primaryViolet.withValues(alpha: 0.08) : AppTheme.cardSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Code, Credits, and Term
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryViolet.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryViolet.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      course.code,
                      style: const TextStyle(
                        color: AppTheme.violetLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Term ${course.term} • ${course.credits} Credits',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppTheme.amberWarning, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    course.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Course Name
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),

          // Professor
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  course.professorName,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Timetable Slot
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppTheme.neonCyan, size: 14),
              const SizedBox(width: 4),
              Text(
                '${course.days.join('/')}  ${course.timeSlot}',
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Workload & Prerequisites
          Row(
            children: [
              const Text('Workload: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              Row(
                children: List.generate(5, (index) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: index < course.workloadLevel ? workloadColor : AppTheme.cardSurfaceLight,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const Spacer(),
              if (course.prerequisites.isNotEmpty)
                Text(
                  'Prereq: ${course.prerequisites.join(', ')}',
                  style: const TextStyle(color: AppTheme.amberWarning, fontSize: 11, fontWeight: FontWeight.w600),
                )
              else
                const Text(
                  'No Prerequisites',
                  style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Industry Skills Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: course.industrySkills.take(3).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Syllabus Copilot + Enroll Toggle
          Row(
            children: [
              if (onSyllabusTap != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSyllabusTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.cyanLight,
                      side: const BorderSide(color: AppTheme.neonCyan),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.auto_stories_rounded, size: 14),
                    label: const Text('Study Plan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              if (onSyllabusTap != null) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? AppTheme.roseDanger.withValues(alpha: 0.8) : AppTheme.primaryViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(isSelected ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded, size: 14),
                  label: Text(
                    isSelected ? 'Drop Course' : 'Enroll Elective',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
