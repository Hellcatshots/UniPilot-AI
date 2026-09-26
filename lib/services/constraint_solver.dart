import '../models/course.dart';
import '../models/conflict_result.dart';
import '../models/student_profile.dart';
import '../data/university_catalog.dart';

class ConstraintSolver {
  /// Solves all schedule, prerequisite, credit, and cognitive workload constraints 100% offline.
  static List<ConflictResult> evaluateSelection({
    required List<Course> selectedCourses,
    required StudentProfile student,
    int maxTermCredits = 15,
    int minTermCredits = 6,
  }) {
    final List<ConflictResult> results = [];

    // 1. TIMETABLE SCHEDULE OVERLAP CHECK (Pairwise validation)
    for (int i = 0; i < selectedCourses.length; i++) {
      for (int j = i + 1; j < selectedCourses.length; j++) {
        final c1 = selectedCourses[i];
        final c2 = selectedCourses[j];

        // Check if both courses are in the same term
        if (c1.term == c2.term) {
          final sharedDays = c1.days.where((d) => c2.days.contains(d)).toList();
          if (sharedDays.isNotEmpty && c1.timeSlotIndex == c2.timeSlotIndex) {
            results.add(
              ConflictResult(
                title: 'Timetable Schedule Collision',
                description: '${c1.code} (${c1.name}) and ${c2.code} (${c2.name}) both meet on ${sharedDays.join('/')} at ${c1.timeSlot}.',
                severity: ConflictSeverity.error,
                affectedCourseCodes: [c1.code, c2.code],
                actionableFix: 'Swap one course with an alternate elective in a different time slot.',
              ),
            );
          }
        }
      }
    }

    // 2. PREREQUISITE VIOLATION CHECK
    for (final course in selectedCourses) {
      for (final prereq in course.prerequisites) {
        final hasCompleted = student.completedCourseCodes.any((c) => c.toUpperCase() == prereq.toUpperCase());
        if (!hasCompleted) {
          final prereqCourse = UniversityCatalog.getCourseByCode(prereq);
          final prereqTitle = prereqCourse != null ? '$prereq (${prereqCourse.name})' : prereq;
          results.add(
            ConflictResult(
              title: 'Missing Prerequisite Requirement',
              description: '${course.code} requires completion of $prereqTitle before enrollment.',
              severity: ConflictSeverity.error,
              affectedCourseCodes: [course.code, prereq],
              actionableFix: 'Enroll in $prereq in Term ${course.term - 1} or submit an academic prerequisite waiver petition.',
            ),
          );
        }
      }
    }

    // 3. CREDIT LIMIT & POLICY VIOLATIONS
    final totalCredits = selectedCourses.fold<int>(0, (sum, c) => sum + c.credits);
    if (totalCredits > maxTermCredits) {
      results.add(
        ConflictResult(
          title: 'Term Credit Ceiling Exceeded',
          description: 'Current selection totals $totalCredits credits. University policy caps Term ${student.currentTerm} enrollment at $maxTermCredits credits.',
          severity: ConflictSeverity.error,
          affectedCourseCodes: selectedCourses.map((c) => c.code).toList(),
          actionableFix: 'Drop at least one 3-credit elective to stay within academic guidelines.',
        ),
      );
    } else if (selectedCourses.isNotEmpty && totalCredits < minTermCredits) {
      results.add(
        ConflictResult(
          title: 'Underloaded Credit Notice',
          description: 'Current selection is only $totalCredits credits (minimum required is $minTermCredits credits for full-time standing).',
          severity: ConflictSeverity.warning,
          affectedCourseCodes: selectedCourses.map((c) => c.code).toList(),
          actionableFix: 'Select an additional 3-credit elective to maintain progress toward graduation.',
        ),
      );
    }

    // 4. COGNITIVE WORKLOAD & BURNOUT HOTSPOT DETECTION
    final heavyCourses = selectedCourses.where((c) => c.workloadLevel >= 4).toList();
    if (heavyCourses.length >= 3) {
      results.add(
        ConflictResult(
          title: 'High Cognitive Workload / Burnout Risk',
          description: 'You have selected 3 intensive quantitative or project-heavy courses (${heavyCourses.map((c) => c.code).join(', ')}). Multiple concurrent deliverables in Midterm Weeks 6-8 may harm your GPA.',
          severity: ConflictSeverity.warning,
          affectedCourseCodes: heavyCourses.map((c) => c.code).toList(),
          actionableFix: 'Consider pairing heavy technical courses with lighter strategic or modular electives.',
        ),
      );
    }

    return results;
  }
}
