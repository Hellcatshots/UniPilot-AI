import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../data/faculty_directory.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

class CampusNavigatorView extends StatelessWidget {
  const CampusNavigatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UniversityRepository>();
    final enrolledCodes = repo.selectedCourses.map((c) => c.code).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          GlassCard(
            backgroundColor: AppTheme.emeraldGreen.withValues(alpha: 0.08),
            borderColor: AppTheme.emeraldGreen.withValues(alpha: 0.4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_rounded, color: AppTheme.emeraldGreen, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Campus Resource & Faculty Navigator',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Directly connects your enrolled electives and career ambitions to professor office hours, research labs, student professional clubs, and conference travel grants.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Faculty Office Hours
          const Text(
            'Recommended Faculty Office Hours & Research Mentors',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: UniversityResources.facultyList.length,
            itemBuilder: (context, idx) {
              final faculty = UniversityResources.facultyList[idx];

              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.3),
                      child: Text(
                        faculty.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.violetLight),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(faculty.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardSurfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(faculty.department, style: const TextStyle(fontSize: 11, color: AppTheme.neonCyan)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(faculty.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(faculty.bio, style: const TextStyle(fontSize: 12, height: 1.4)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_filled_rounded, color: AppTheme.amberWarning, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Office Hours: ${faculty.officeHours}', style: const TextStyle(fontSize: 12, color: AppTheme.amberWarning, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded, color: AppTheme.textMuted, size: 14),
                                  const SizedBox(width: 4),
                                  Text(faculty.officeLocation, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('📅 Appointment slot requested with ${faculty.name}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, size: 14),
                      label: const Text('Book 1:1 Slot', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Labs, Clubs & Funding Opportunities
          const Text(
            'Specialized Labs, Professional Guilds & Conference Grants',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.6,
                ),
                itemCount: UniversityResources.resources.length,
                itemBuilder: (context, idx) {
                  final res = UniversityResources.resources[idx];
                  final isMatched = res.relevantCourseCodes.any((c) => enrolledCodes.contains(c));

                  return GlassCard(
                    borderColor: isMatched ? AppTheme.neonCyan : AppTheme.borderColor,
                    backgroundColor: isMatched ? AppTheme.neonCyan.withValues(alpha: 0.05) : AppTheme.cardSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                res.category.toUpperCase(),
                                style: const TextStyle(color: AppTheme.neonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            if (isMatched)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Matches Enrolled Electives', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(res.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        Expanded(child: Text(res.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(res.contactOrLocation, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
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
