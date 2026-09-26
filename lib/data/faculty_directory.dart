class FacultyMember {
  final String id;
  final String name;
  final String title;
  final String department;
  final String email;
  final String officeLocation;
  final String officeHours;
  final List<String> expertiseKeywords;
  final String bio;

  const FacultyMember({
    required this.id,
    required this.name,
    required this.title,
    required this.department,
    required this.email,
    required this.officeLocation,
    required this.officeHours,
    required this.expertiseKeywords,
    required this.bio,
  });
}

class CampusResource {
  final String id;
  final String name;
  final String category; // 'Lab & Tech', 'Student Club', 'Grant & Funding', 'Career Center'
  final String description;
  final String contactOrLocation;
  final List<String> relevantCourseCodes;

  const CampusResource({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.contactOrLocation,
    required this.relevantCourseCodes,
  });
}

class UniversityResources {
  static const List<FacultyMember> facultyList = [
    FacultyMember(
      id: 'fac_1',
      name: 'Prof. Ananya Sen',
      title: 'Professor of Practice, Product & Technology',
      department: 'Product & Tech',
      email: 'ananya.sen@university.edu.in',
      officeLocation: 'Academic Block B, Suite 304',
      officeHours: 'Tuesdays & Thursdays: 14:00 - 16:00',
      expertiseKeywords: ['Product Management', 'Startup Discovery', 'B2B SaaS', 'User Research'],
      bio: 'Former VP of Product at Flipkart with 14 years leading e-commerce marketplaces and consumer mobile products.',
    ),
    FacultyMember(
      id: 'fac_2',
      name: 'Dr. Siddharth Menon',
      title: 'Associate Professor, Investment Banking & Finance',
      department: 'Finance',
      email: 'siddharth.menon@university.edu.in',
      officeLocation: 'Management Tower, Floor 4, Rm 412',
      officeHours: 'Wednesdays: 11:00 - 13:00',
      expertiseKeywords: ['Corporate Valuation', 'LBO', 'M&A', 'Private Equity', 'Financial Modeling'],
      bio: 'Ex-Executive Director at Barclays Capital London; focuses on cross-border acquisitions and capital restructuring.',
    ),
    FacultyMember(
      id: 'fac_3',
      name: 'Dr. Rajesh Subramanian',
      title: 'Chair of Data Science & Machine Learning',
      department: 'AI & Analytics',
      email: 'rajesh.s@university.edu.in',
      officeLocation: 'AI Computing Hub, Lab 102',
      officeHours: 'Mondays & Fridays: 15:30 - 17:00',
      expertiseKeywords: ['Machine Learning', 'Big Data Architecture', 'Predictive Modeling', 'Python'],
      bio: 'PhD from IISc; consults for top tech conglomerates on automated credit underwriting and churn prevention models.',
    ),
    FacultyMember(
      id: 'fac_4',
      name: 'Prof. K. Ramanathan',
      title: 'Senior Fellow, Strategy & Enterprise Leadership',
      department: 'Strategy',
      email: 'k.ramanathan@university.edu.in',
      officeLocation: 'Executive Wing, Suite 101',
      officeHours: 'Wednesdays: 14:00 - 16:00 (By Appointment)',
      expertiseKeywords: ['Management Consulting', 'Disruptive Innovation', 'Market Entry', 'Boardroom Strategy'],
      bio: 'Former Senior Partner at McKinsey & Company with 22 years of advising Fortune 500 boards across Asia and Europe.',
    ),
  ];

  static const List<CampusResource> resources = [
    CampusResource(
      id: 'res_1',
      name: 'Bloomberg Financial Markets & Trading Lab',
      category: 'Lab & Tech',
      description: '12 dedicated Bloomberg Professional terminals with real-time equity, fixed income, and commodities data.',
      contactOrLocation: 'Finance Block 2nd Floor, Room 204 • Open 08:00 - 22:00',
      relevantCourseCodes: ['FIN601', 'FIN702', 'FIN720'],
    ),
    CampusResource(
      id: 'res_2',
      name: 'University AI High-Performance GPU Cluster',
      category: 'Lab & Tech',
      description: 'NVIDIA H100 and A100 compute nodes available for student deep learning training, thesis projects, and agent development.',
      contactOrLocation: 'Request slurm access via hpc@university.edu.in',
      relevantCourseCodes: ['AID710', 'AID730', 'PMT710'],
    ),
    CampusResource(
      id: 'res_3',
      name: 'The Product Management & Tech Guild',
      category: 'Student Club',
      description: 'Organizes mock PM interviews, weekly teardowns of unicorn apps, and industry fireside chats with Chief Product Officers.',
      contactOrLocation: 'pm-guild@university.edu.in • Meets Thursdays 18:00',
      relevantCourseCodes: ['PMT650', 'PMT670', 'PMT710'],
    ),
    CampusResource(
      id: 'res_4',
      name: 'Management Consulting & Strategy Society',
      category: 'Student Club',
      description: 'Intensive peer case-cracking, live consulting engagements for regional SMEs, and McKinsey/BCG partner mentorship.',
      contactOrLocation: 'consulting.club@university.edu.in • Meets Tuesdays 18:30',
      relevantCourseCodes: ['STR620', 'STR710'],
    ),
    CampusResource(
      id: 'res_5',
      name: 'Dean’s International Student Conference Grant',
      category: 'Grant & Funding',
      description: 'Up to ₹1,50,000 travel and registration subsidy for students presenting peer-reviewed research or winning national pitch fests.',
      contactOrLocation: 'Apply via Academic Office Portal before 15th of each month',
      relevantCourseCodes: ['AID730', 'PMT710', 'FIN740'],
    ),
  ];
}
