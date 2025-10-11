class JobModel {
  final String id;
  final String title;
  final String company;
  final String description;
  final double minCGPA;
  final double? minTenthPercentage;
  final double? minTwelfthPercentage;
  final List<String> eligibleBranches;
  final List<String> requiredSkills;
  final bool requiresResume;
  final List<AptitudeQuestion> aptitudeQuestions;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.minCGPA,
    this.minTenthPercentage,
    this.minTwelfthPercentage,
    required this.eligibleBranches,
    required this.requiredSkills,
    this.requiresResume = true,
    required this.aptitudeQuestions,
  });

  static List<JobModel> getSampleJobs() {
    return [
      JobModel(
        id: '1',
        title: 'Software Developer',
        company: 'Accenture',
        description:
            'Develop and maintain software applications using modern technologies',
        minCGPA: 7.5,
        minTenthPercentage: 75,
        minTwelfthPercentage: 75,
        eligibleBranches: ['CSE', 'IT', 'ECS'],
        requiredSkills: ['Java', 'Python', 'React', 'SQL', 'C++'],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '1_1',
              question: 'What is the time complexity of binary search?',
              options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '1_2',
              question:
                  'Which programming paradigm does Java primarily support?',
              options: ['Functional', 'Object-Oriented', 'Procedural', 'Logic'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '1_3',
              question: 'What does SQL stand for?',
              options: [
                'Structured Query Language',
                'Simple Query Language',
                'System Query Language',
                'Standard Query Language'
              ],
              correctAnswer: 0),
        ],
      ),
      JobModel(
        id: '2',
        title: 'Data Analyst',
        company: 'Deloitte',
        description:
            'Analyze and interpret complex data sets to help business decision-making',
        minCGPA: 7.0,
        minTenthPercentage: 70,
        minTwelfthPercentage: 70,
        eligibleBranches: ['CSE', 'IT', 'ECS', 'EXTC'],
        requiredSkills: ['Python', 'R', 'Excel', 'Statistics', 'Power BI'],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '2_1',
              question: 'What is the mean of the dataset: 2, 4, 6, 8, 10?',
              options: ['5', '6', '7', '8'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '2_2',
              question:
                  'Which Python library is commonly used for data manipulation?',
              options: ['NumPy', 'Pandas', 'Matplotlib', 'Scikit-learn'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '2_3',
              question:
                  'What type of chart is best for showing correlation between two variables?',
              options: ['Bar Chart', 'Pie Chart', 'Scatter Plot', 'Line Chart'],
              correctAnswer: 2),
        ],
      ),
      JobModel(
        id: '3',
        title: 'Graduate Engineer Trainee',
        company: 'L&T',
        description:
            'Entry-level position for fresh graduates with comprehensive training.',
        minCGPA: 6.5,
        minTenthPercentage: 65,
        eligibleBranches: ['MECH', 'CIVIL', 'ECS', 'EXTC'],
        requiredSkills: ['CAD', 'SolidWorks', 'Teamwork'],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '3_1',
              question: 'What is the SI unit of force?',
              options: ['Joule', 'Newton', 'Watt', 'Pascal'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '3_2',
              question:
                  "Which law states that for every action, there is an equal and opposite reaction?",
              options: [
                "Newton's First Law",
                "Newton's Second Law",
                "Newton's Third Law",
                'Law of Gravitation'
              ],
              correctAnswer: 2),
          AptitudeQuestion(
              id: '3_3',
              question:
                  'What is the process of joining two metal pieces using heat?',
              options: ['Casting', 'Forging', 'Welding', 'Machining'],
              correctAnswer: 2),
        ],
      ),
      JobModel(
        id: '4',
        title: 'Frontend Developer',
        company: 'SLRTCE',
        description:
            'Create responsive and interactive web user interfaces for internal college projects.',
        minCGPA: 7.2,
        eligibleBranches: ['CSE', 'IT', 'ECS'],
        requiredSkills: ['HTML', 'CSS', 'JavaScript', 'React'],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '4_1',
              question: 'Which HTML tag is used for creating hyperlinks?',
              options: ['<link>', '<a>', '<href>', '<url>'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '4_2',
              question: 'What does CSS stand for?',
              options: [
                'Computer Style Sheets',
                'Cascading Style Sheets',
                'Creative Style Sheets',
                'Colorful Style Sheets'
              ],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '4_3',
              question:
                  'Which JavaScript method is used to add an element to the end of an array?',
              options: ['push()', 'pop()', 'shift()', 'unshift()'],
              correctAnswer: 0),
        ],
      ),
      JobModel(
        id: '5',
        title: 'Product Manager (Associate)',
        company: 'Wipro',
        description:
            'Entry-level position for fresh graduates with a comprehensive training program in product lifecycle management.',
        minCGPA: 6.0,
        eligibleBranches: ['CSE', 'IT', 'ECS', 'EXTC', 'MECH', 'CIVIL'],
        requiredSkills: ['Communication', 'Problem Solving', 'Teamwork'],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '5_1',
              question: 'What is 25% of 200?',
              options: ['25', '50', '75', '100'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '5_2',
              question:
                  'If today is Monday, what day will it be after 10 days?',
              options: ['Wednesday', 'Thursday', 'Friday', 'Saturday'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '5_3',
              question: 'Complete the sequence: 2, 4, 8, 16, ?',
              options: ['24', '32', '30', '28'],
              correctAnswer: 1),
        ],
      ),
      JobModel(
        id: '6',
        title: 'Site Engineer',
        company: 'Tata Projects',
        description:
            'Oversee and manage construction projects on-site, ensuring quality and timelines.',
        minCGPA: 6.8,
        eligibleBranches: ['CIVIL'],
        requiredSkills: [
          'AutoCAD',
          'Project Management',
          'Concrete Technology'
        ],
        requiresResume: true,
        aptitudeQuestions: [
          AptitudeQuestion(
              id: '6_1',
              question: 'The slump test is performed to determine the:',
              options: [
                'Strength of Concrete',
                'Workability of Concrete',
                'Water Content',
                'Durability'
              ],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '6_2',
              question:
                  'Which IS code is used for general construction in steel structures?',
              options: ['IS 456', 'IS 800', 'IS 875', 'IS 1200'],
              correctAnswer: 1),
          AptitudeQuestion(
              id: '6_3',
              question: 'What does CPM stand for in construction management?',
              options: [
                'Construction Project Manager',
                'Cost Per Mile',
                'Critical Path Method',
                'Contractor Payment Model'
              ],
              correctAnswer: 2),
        ],
      ),
    ];
  }
}

class AptitudeQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;

  AptitudeQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
      };

  factory AptitudeQuestion.fromJson(Map<String, dynamic> json) =>
      AptitudeQuestion(
        id: json['id'],
        question: json['question'],
        options: List<String>.from(json['options']),
        correctAnswer: json['correctAnswer'],
      );
}

class AptitudeTestResult {
  final String jobId;
  final int totalQuestions;
  final int correctAnswers;
  final bool passed;
  final DateTime completedAt;

  AptitudeTestResult({
    required this.jobId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passed,
    required this.completedAt,
  });

  double get scorePercentage => (correctAnswers / totalQuestions) * 100;

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'passed': passed,
        // FIX: Corrected method name from toIso861String to toIso8601String
        'completedAt': completedAt.toIso8601String(),
      };

  factory AptitudeTestResult.fromJson(Map<String, dynamic> json) =>
      AptitudeTestResult(
        jobId: json['jobId'],
        totalQuestions: json['totalQuestions'],
        correctAnswers: json['correctAnswers'],
        passed: json['passed'],
        completedAt: DateTime.parse(json['completedAt']),
      );
}
