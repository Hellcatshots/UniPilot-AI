class StudentProfile {
  final String id;
  final String name;
  final String email;
  final String program;
  final int currentTerm;
  final double currentGpa;
  String careerAmbition;
  List<String> completedCourseCodes;
  List<String> selectedCourseIds;
  List<String> targetSkills;

  StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.program,
    required this.currentTerm,
    required this.currentGpa,
    required this.careerAmbition,
    required this.completedCourseCodes,
    required this.selectedCourseIds,
    required this.targetSkills,
  });

  StudentProfile copyWith({
    String? careerAmbition,
    List<String>? completedCourseCodes,
    List<String>? selectedCourseIds,
    List<String>? targetSkills,
    double? currentGpa,
  }) {
    return StudentProfile(
      id: id,
      name: name,
      email: email,
      program: program,
      currentTerm: currentTerm,
      currentGpa: currentGpa ?? this.currentGpa,
      careerAmbition: careerAmbition ?? this.careerAmbition,
      completedCourseCodes: completedCourseCodes ?? List.from(this.completedCourseCodes),
      selectedCourseIds: selectedCourseIds ?? List.from(this.selectedCourseIds),
      targetSkills: targetSkills ?? List.from(this.targetSkills),
    );
  }
}
