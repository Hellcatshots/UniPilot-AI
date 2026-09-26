import 'package:flutter_test/flutter_test.dart';
import 'package:unipilot_app/services/hybrid_ai_service.dart';
import 'package:unipilot_app/services/university_repository.dart';

void main() {
  test('UniversityRepository and HybridAiService state transitions cleanly', () {
    final repo = UniversityRepository();
    expect(repo.activeStudent.name, isNotEmpty);
    expect(repo.selectedCourses, isNotEmpty);
    expect(repo.totalEnrolledCredits, greaterThan(0));

    final ai = HybridAiService();
    expect(ai.isCloudBoost, isTrue);
    ai.toggleEngineMode();
    expect(ai.isEdgeOffline, isTrue);
    ai.toggleEngineMode();
    expect(ai.isCloudBoost, isTrue);
  });
}
