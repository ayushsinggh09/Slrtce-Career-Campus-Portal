class StudentModel {
  // Basic Details
  final String name;
  final String email;
  final String phone;
  final String branch;
  final String batchYear;
  final String rollNumber;
  final String? profilePicturePath;

  // Academic Details
  final double? tenthPercentage;
  final double? twelfthPercentage;
  final double? diplomaPercentage;

  // Semester Results (8 semesters)
  final List<double?> semesterGPAs;

  // Skills
  final List<String> skills;

  // Documents
  final String? resumePath;
  final List<String> certificatePaths;

  // Job Applications
  final List<String> appliedJobIds;

  StudentModel({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.branch = '',
    this.batchYear = '',
    this.rollNumber = '',
    this.profilePicturePath,
    this.tenthPercentage,
    this.twelfthPercentage,
    this.diplomaPercentage,
    List<double?>? semesterGPAs,
    List<String>? skills,
    this.resumePath,
    List<String>? certificatePaths,
    List<String>? appliedJobIds,
  })  : semesterGPAs = semesterGPAs ?? List.filled(8, null),
        skills = skills ?? [],
        certificatePaths = certificatePaths ?? [],
        appliedJobIds = appliedJobIds ?? [];

  double get cgpa {
    final validGPAs = semesterGPAs.whereType<double>().toList();
    if (validGPAs.isEmpty) return 0.0;
    return validGPAs.reduce((a, b) => a + b) / validGPAs.length; //avg
  }

  int get completedSemesters {
    return semesterGPAs.where((gpa) => gpa != null).length;
  }

  double get profileCompletion {
    double total = 0;
    double completed = 0;

    total += 6; // name, email, phone, branch, batch, rollNumber compuls... part to fill
    if (name.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (phone.isNotEmpty) completed++;
    if (branch.isNotEmpty) completed++;
    if (batchYear.isNotEmpty) completed++;
    if (rollNumber.isNotEmpty) completed++;

    total += 1; // profile picture
    if (profilePicturePath != null && profilePicturePath!.isNotEmpty) completed++;

    total += 2; // 10th and 12th
    if (tenthPercentage != null) completed++;
    if (twelfthPercentage != null) completed++;

    total += 8; // semesters
    completed += completedSemesters;

    total += 1; // skills
    if (skills.isNotEmpty) completed++;

    total += 1; // resume
    if (resumePath != null && resumePath!.isNotEmpty) completed++;

    return (completed / total) * 100;
  }

  StudentModel copyWith({      //update  ctreate
    String? name,
    String? email,
    String? phone,
    String? branch,
    String? batchYear,
    String? rollNumber,
    String? profilePicturePath,
    double? tenthPercentage,
    double? twelfthPercentage,
    double? diplomaPercentage,
    List<double?>? semesterGPAs,
    List<String>? skills,
    String? resumePath,
    List<String>? certificatePaths,
    List<String>? appliedJobIds,
  }) {
    return StudentModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      branch: branch ?? this.branch,
      batchYear: batchYear ?? this.batchYear,
      rollNumber: rollNumber ?? this.rollNumber,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      tenthPercentage: tenthPercentage ?? this.tenthPercentage,
      twelfthPercentage: twelfthPercentage ?? this.twelfthPercentage,
      diplomaPercentage: diplomaPercentage ?? this.diplomaPercentage,
      semesterGPAs: semesterGPAs ?? this.semesterGPAs,
      skills: skills ?? this.skills,
      resumePath: resumePath ?? this.resumePath,
      certificatePaths: certificatePaths ?? this.certificatePaths,
      appliedJobIds: appliedJobIds ?? this.appliedJobIds,
    );
  }

  Map<String, dynamic> toJson() {    // to firebase send
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'branch': branch,
      'batchYear': batchYear,
      'rollNumber': rollNumber,
      'profilePicturePath': profilePicturePath,
      'tenthPercentage': tenthPercentage,
      'twelfthPercentage': twelfthPercentage,
      'diplomaPercentage': diplomaPercentage,
      'semesterGPAs': semesterGPAs,
      'skills': skills,
      'resumePath': resumePath,
      'certificatePaths': certificatePaths,
      'appliedJobIds': appliedJobIds,
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {    // retrived from firebase
    return StudentModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      branch: json['branch'] ?? '',
      batchYear: json['batchYear'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      profilePicturePath: json['profilePicturePath'],
      tenthPercentage: (json['tenthPercentage'] as num?)?.toDouble(),
      twelfthPercentage: (json['twelfthPercentage'] as num?)?.toDouble(),
      diplomaPercentage: (json['diplomaPercentage'] as num?)?.toDouble(),
      semesterGPAs: (json['semesterGPAs'] as List?)
          ?.map((e) => (e as num?)?.toDouble())
          .toList() ??
          List.filled(8, null),
      skills: List<String>.from(json['skills'] ?? []),
      resumePath: json['resumePath'],
      certificatePaths: List<String>.from(json['certificatePaths'] ?? []),
      appliedJobIds: List<String>.from(json['appliedJobIds'] ?? []),
    );
  }
}