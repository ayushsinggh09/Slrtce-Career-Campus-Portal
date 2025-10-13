class AlumniModel {
  final String id;
  final String name;
  final String branch;
  final String batch;
  final String currentPosition;
  final String currentCompany;
  final String? profileImagePath;
  final List<String> achievements;

  AlumniModel({
    required this.id,
    required this.name,
    required this.branch,
    required this.batch,
    required this.currentPosition,
    required this.currentCompany,
    this.profileImagePath,
    this.achievements = const [],
  });

   // for new alumni updated through Firebase (in december)
  static List<AlumniModel> getSampleAlumni() {
    return [
      AlumniModel(
        id: '1',
        name: 'Shubham Patel',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Content Creater',
        currentCompany: 'Capgemini',
        profileImagePath: 'assets/images/alumni_1.jpg', 
        achievements: ['+1M followers on social media'],
      ),
      AlumniModel(
        id: '2',
        name: 'Hardik Rajpurohit',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Data Scientist',
        currentCompany: 'Dream 11',
        profileImagePath: 'assets/images/alumni_2.jpg',
        achievements: ['Online Fantasy Winner 5x'],
      ),
      AlumniModel(
        id: '3',
        name: 'Rahul Prasad',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Assistant Professors',
        currentCompany: 'Physics Wallah',
        profileImagePath: 'assets/images/alumni_3.jpg',
        achievements: ['Winner of Science Exhibition 2x'],
      ),
      AlumniModel(
        id: '4',
        name: 'Sunny Singh',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Fitness consultant',
        currentCompany: 'Nitrro',
        profileImagePath: 'assets/images/alumni_4.jpg',
        achievements: ['Most push ups in 10 minutes'],
      ),
      AlumniModel(
        id: '5',
        name: 'Adarsh Yadav',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Software Engineer',
        currentCompany: 'Accenture',
        profileImagePath: 'assets/images/alumni_5.jpg',
        achievements: ['Leadership Excellence'],
      ),
      AlumniModel(
        id: '6',
        name: 'Shreyash Singh',
        branch: 'ECs',
        batch: '2023',
        currentPosition: 'Full Stack Developer',
        currentCompany: 'JIO',
        profileImagePath: 'assets/images/alumni_6.jpg',
        achievements: ['Hack4bihar winner 4x'],

      ),
      AlumniModel(
        id: '7',
        name: 'Himanshu Yadav',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Data Analytics',
        currentCompany: 'Stake',
        profileImagePath: 'assets/images/alumni_7.jpg',
        achievements: ['Stake Brand Ambassador'],
      ),
      AlumniModel(
        id: '8',
        name: 'Ved Sharma',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'UI/UX Design',
        currentCompany: 'Deloite',
        profileImagePath: 'assets/images/alumni_8.jpeg',
        achievements: ['Technical Excellence']
      ),
      AlumniModel(
        id: '9',
        name: 'Ayush Singh',
        branch: 'ECS',
        batch: '2023',
        currentPosition: 'Software Developer',
        currentCompany: 'KPMG',
        profileImagePath: 'assets/images/alumni_9.png',
        achievements: ['Stock Predication']
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branch': branch,
      'batch': batch,
      'currentPosition': currentPosition,
      'currentCompany': currentCompany,
      'profileImagePath': profileImagePath,
      'achievements': achievements,
    };
  }

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      id: json['id'],
      name: json['name'],
      branch: json['branch'],
      batch: json['batch'],
      currentPosition: json['currentPosition'],
      currentCompany: json['currentCompany'],
      profileImagePath: json['profileImagePath'],
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }
  int get achievementCount => achievements.length;
  bool get hasProfilePicture =>
      profileImagePath != null && profileImagePath!.isNotEmpty;
  String get firstName {
    return name.split(' ').first;
  }

  int get graduationYear {
    return int.tryParse(batch) ?? DateTime.now().year;
  }


  bool get isRecentGraduate {
    final currentYear = DateTime.now().year;
    return (currentYear - graduationYear) <= 2;
  }
}