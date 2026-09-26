import '../models/student_profile.dart';

class StudentPersonas {
  static final List<StudentProfile> demoPersonas = [
    StudentProfile(
      id: 'persona_arjun',
      name: 'Arjun Mehta',
      email: 'arjun.m25@university.edu.in',
      program: 'MBA (Tech & Management)',
      currentTerm: 2,
      currentGpa: 3.65,
      careerAmbition: 'FinTech Product Manager',
      completedCourseCodes: ['AID601', 'FIN601', 'STR620'],
      selectedCourseIds: ['pmt_650', 'pmt_670'], // Product Strategy + Analytics
      targetSkills: ['Product Discovery', 'A/B Testing', 'Payment Gateways', 'Financial Modeling', 'SQL'],
    ),
    StudentProfile(
      id: 'persona_priya',
      name: 'Priya Sharma',
      email: 'priya.s24@university.edu.in',
      program: 'M.S. in Applied AI & Data Science',
      currentTerm: 2,
      currentGpa: 3.82,
      careerAmbition: 'GenAI & Applied ML Systems Architect',
      completedCourseCodes: ['AID601', 'AID710'],
      selectedCourseIds: ['aid_730', 'pmt_710'],
      targetSkills: ['Transformers', 'PyTorch', 'Vector DBs', 'Model Deployment', 'Agentic UX'],
    ),
    StudentProfile(
      id: 'persona_rohan',
      name: 'Rohan Nair',
      email: 'rohan.n25@university.edu.in',
      program: 'MBA (Strategy & Finance)',
      currentTerm: 2,
      currentGpa: 3.42,
      careerAmbition: 'Strategy & Management Consultant',
      completedCourseCodes: ['STR620', 'AID601'],
      selectedCourseIds: ['str_710', 'fin_702'],
      targetSkills: ['MECE Frameworks', 'Hypothesis-Driven Problem Solving', 'Corporate Valuation', 'Issue Trees'],
    ),
  ];
}
