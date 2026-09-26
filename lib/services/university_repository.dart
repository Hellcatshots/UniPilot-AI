import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/student_profile.dart';
import '../models/conflict_result.dart';
import '../data/university_catalog.dart';
import '../data/student_personas.dart';
import 'constraint_solver.dart';

class UniversityRepository extends ChangeNotifier {
  static final UniversityRepository _instance = UniversityRepository._internal();
  factory UniversityRepository() => _instance;
  UniversityRepository._internal() {
    _activeStudent = StudentPersonas.demoPersonas.first;
    _recalculateConflicts();
  }

  late StudentProfile _activeStudent;
  List<ConflictResult> _currentConflicts = [];

  StudentProfile get activeStudent => _activeStudent;
  List<ConflictResult> get currentConflicts => _currentConflicts;

  List<Course> get selectedCourses {
    return _activeStudent.selectedCourseIds
        .map((id) => UniversityCatalog.getCourseById(id))
        .whereType<Course>()
        .toList();
  }

  int get totalEnrolledCredits {
    return selectedCourses.fold(0, (sum, c) => sum + c.credits);
  }

  void switchStudentPersona(StudentProfile persona) {
    _activeStudent = persona.copyWith();
    _recalculateConflicts();
    notifyListeners();
  }

  void updateCareerAmbition(String newAmbition) {
    _activeStudent.careerAmbition = newAmbition;
    notifyListeners();
  }

  bool isCourseSelected(String courseId) {
    return _activeStudent.selectedCourseIds.contains(courseId);
  }

  void toggleCourseEnrollment(String courseId) {
    if (_activeStudent.selectedCourseIds.contains(courseId)) {
      _activeStudent.selectedCourseIds.remove(courseId);
    } else {
      _activeStudent.selectedCourseIds.add(courseId);
    }
    _recalculateConflicts();
    notifyListeners();
  }

  void setEnrolledCourses(List<String> courseIds) {
    _activeStudent.selectedCourseIds = List.from(courseIds);
    _recalculateConflicts();
    notifyListeners();
  }

  void resolveAllConflictsAutoBalance() {
    // Drop overlapping courses or replace with non-clashing ones
    if (isCourseSelected('fin_702') && isCourseSelected('pmt_670')) {
      // Both meet Tue/Thu 10:45-12:15. Swap one with PMT710 or AID710
      _activeStudent.selectedCourseIds.remove('fin_702');
      _activeStudent.selectedCourseIds.add('pmt_710');
    }
    if (isCourseSelected('aid_740') && isCourseSelected('pmt_650')) {
      // Both meet Mon/Wed 09:00-10:30
      _activeStudent.selectedCourseIds.remove('aid_740');
      _activeStudent.selectedCourseIds.add('aid_710');
    }
    _recalculateConflicts();
    notifyListeners();
  }

  void _recalculateConflicts() {
    _currentConflicts = ConstraintSolver.evaluateSelection(
      selectedCourses: selectedCourses,
      student: _activeStudent,
    );
  }
}
