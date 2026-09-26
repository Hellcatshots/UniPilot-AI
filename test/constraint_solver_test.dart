import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot_app/data/university_catalog.dart';
import 'package:unipilot_app/models/conflict_result.dart';
import 'package:unipilot_app/models/student_profile.dart';
import 'package:unipilot_app/services/constraint_solver.dart';

void main() {
  group('Deterministic ConstraintSolver Unit Tests', () {
    test('Detects schedule collision when courses meet on same day & slot', () {
      final student = StudentProfile(
        id: 'test_1',
        name: 'Test Student',
        email: 'test@uni.edu',
        program: 'MBA',
        currentTerm: 2,
        currentGpa: 3.5,
        careerAmbition: 'Product Manager',
        completedCourseCodes: ['AID601', 'FIN601'],
        selectedCourseIds: [],
        targetSkills: [],
      );

      // Both PMT670 and FIN702 meet on Tue/Thu at 10:45 - 12:15
      final pmt670 = UniversityCatalog.getCourseById('pmt_670')!;
      final fin702 = UniversityCatalog.getCourseById('fin_702')!;

      final conflicts = ConstraintSolver.evaluateSelection(
        selectedCourses: [pmt670, fin702],
        student: student,
      );

      final hasCollision = conflicts.any(
        (c) => c.title == 'Timetable Schedule Collision' && c.severity == ConflictSeverity.error,
      );
      expect(hasCollision, isTrue);
    });

    test('Detects missing prerequisite when student has not completed required course', () {
      final student = StudentProfile(
        id: 'test_2',
        name: 'Test Student 2',
        email: 'test2@uni.edu',
        program: 'MBA',
        currentTerm: 2,
        currentGpa: 3.5,
        careerAmbition: 'Finance',
        completedCourseCodes: [], // No prerequisites completed
        selectedCourseIds: [],
        targetSkills: [],
      );

      // FIN702 requires FIN601
      final fin702 = UniversityCatalog.getCourseById('fin_702')!;

      final conflicts = ConstraintSolver.evaluateSelection(
        selectedCourses: [fin702],
        student: student,
      );

      final hasPrereqError = conflicts.any(
        (c) => c.title == 'Missing Prerequisite Requirement' && c.severity == ConflictSeverity.error,
      );
      expect(hasPrereqError, isTrue);
    });

    test('Validates clean schedule with 0 errors when courses are compatible', () {
      final student = StudentProfile(
        id: 'test_3',
        name: 'Test Student 3',
        email: 'test3@uni.edu',
        program: 'MBA',
        currentTerm: 2,
        currentGpa: 3.5,
        careerAmbition: 'Product Manager',
        completedCourseCodes: ['AID601', 'FIN601'],
        selectedCourseIds: [],
        targetSkills: [],
      );

      // PMT650 (Mon/Wed 09:00-10:30) and PMT670 (Tue/Thu 10:45-12:15)
      final pmt650 = UniversityCatalog.getCourseById('pmt_650')!;
      final pmt670 = UniversityCatalog.getCourseById('pmt_670')!;

      final conflicts = ConstraintSolver.evaluateSelection(
        selectedCourses: [pmt650, pmt670],
        student: student,
      );

      final errorConflicts = conflicts.where((c) => c.severity == ConflictSeverity.error).toList();
      expect(errorConflicts.isEmpty, isTrue);
    });
  });
}
