class Course {
  final String id;
  final String code;
  final String name;
  final String department;
  final int credits;
  final int term; // 1, 2, or 3
  final List<String> days; // e.g. ['Mon', 'Wed']
  final String timeSlot; // e.g. '09:00 - 10:30'
  final int timeSlotIndex; // 0: 9-10:30, 1: 10:45-12:15, 2: 13:30-15:00, 3: 15:15-16:45
  final List<String> prerequisites; // Course codes e.g. ['FIN601']
  final String professorName;
  final double rating;
  final int workloadLevel; // 1 (Light) to 5 (Heavy Quant/Project)
  final List<String> industrySkills;
  final String syllabusSummary;
  final String assessmentFormat; // e.g., '40% Midterm, 40% Final Case Study, 20% Quizzes'

  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.department,
    required this.credits,
    required this.term,
    required this.days,
    required this.timeSlot,
    required this.timeSlotIndex,
    required this.prerequisites,
    required this.professorName,
    required this.rating,
    required this.workloadLevel,
    required this.industrySkills,
    required this.syllabusSummary,
    required this.assessmentFormat,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'department': department,
    'credits': credits,
    'term': term,
    'days': days,
    'timeSlot': timeSlot,
    'timeSlotIndex': timeSlotIndex,
    'prerequisites': prerequisites,
    'professorName': professorName,
    'rating': rating,
    'workloadLevel': workloadLevel,
    'industrySkills': industrySkills,
    'syllabusSummary': syllabusSummary,
    'assessmentFormat': assessmentFormat,
  };
}
