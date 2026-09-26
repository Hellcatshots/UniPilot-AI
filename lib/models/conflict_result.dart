enum ConflictSeverity { warning, error, info }

class ConflictResult {
  final String title;
  final String description;
  final ConflictSeverity severity;
  final List<String> affectedCourseCodes;
  final String actionableFix;

  const ConflictResult({
    required this.title,
    required this.description,
    required this.severity,
    required this.affectedCourseCodes,
    required this.actionableFix,
  });
}
