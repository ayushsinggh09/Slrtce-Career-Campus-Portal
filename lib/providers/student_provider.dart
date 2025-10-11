import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../models/job_model.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StudentModel _student = StudentModel();
  final List<JobModel> _jobs = JobModel.getSampleJobs();
  final Map<String, AptitudeTestResult> _aptitudeResults = {};

  bool _isLoading = false;
  String? _error;

  StudentModel get student => _student;
  List<JobModel> get jobs => _jobs;
  Map<String, AptitudeTestResult> get aptitudeResults => _aptitudeResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StudentProvider() {
    _initializeStudent();
  }

  void _initializeStudent() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loadStudentData();
      } else {
        _student = StudentModel();
        _aptitudeResults.clear();
        notifyListeners();
      }
    });
  }

  Future<void> loadStudentData() async {
    await loadStudent();
    await loadAptitudeResults();
  }

  Future<void> loadStudent() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('students').doc(user.uid).get();
      if (doc.exists) {
        _student = StudentModel.fromJson(doc.data()!);
      } else {
        _student =
            StudentModel(email: user.email ?? '', name: user.displayName ?? '');
        await saveStudent();
      }
    } catch (e) {
      _error = 'Failed to load student data: ${e.toString()}';
      if (kDebugMode) print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveStudent() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('students').doc(user.uid).set(
        {..._student.toJson(), 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) print('Error saving student data: $e');
      rethrow;
    }
  }

  Future<void> updateBasicDetails(
      {String? name,
      String? phone,
      String? branch,
      String? batchYear,
      String? rollNumber}) async {
    _student = _student.copyWith(
        name: name,
        phone: phone,
        branch: branch,
        batchYear: batchYear,
        rollNumber: rollNumber);
    await saveStudent();
    notifyListeners();
  }

  Future<void> updateProfilePicture(String? url) async {
    _student = _student.copyWith(profilePicturePath: url);
    await saveStudent();
    notifyListeners();
  }

  Future<void> updateSkills(List<String> skills) async {
    _student = _student.copyWith(skills: skills);
    await saveStudent();
    notifyListeners();
  }

  Future<void> updateAcademicDetails(
      {double? tenthPercentage,
      double? twelfthPercentage,
      double? diplomaPercentage}) async {
    _student = _student.copyWith(
        tenthPercentage: tenthPercentage,
        twelfthPercentage: twelfthPercentage,
        diplomaPercentage: diplomaPercentage);
    await saveStudent();
    notifyListeners();
  }

  Future<void> updateSemesterGPA(int semester, double? gpa) async {
    final newGPAs = List<double?>.from(_student.semesterGPAs);
    newGPAs[semester - 1] = gpa;
    _student = _student.copyWith(semesterGPAs: newGPAs);
    await saveStudent();
    notifyListeners();
  }

  Future<void> updateResume(String? url) async {
    _student = _student.copyWith(resumePath: url);
    await saveStudent();
    notifyListeners();
  }

  Future<void> addCertificate(String url) async {
    final newCertificates = List<String>.from(_student.certificatePaths)
      ..add(url);
    _student = _student.copyWith(certificatePaths: newCertificates);
    await saveStudent();
    notifyListeners();
  }

  Future<void> removeCertificate(String url) async {
    final newCertificates = List<String>.from(_student.certificatePaths)
      ..remove(url);
    _student = _student.copyWith(certificatePaths: newCertificates);
    await saveStudent();
    notifyListeners();
  }

  // UPDATED: More complete eligibility check
  bool isEligibleForJob(JobModel job) {
    if (_student.cgpa < job.minCGPA) return false;

    if (job.minTenthPercentage != null &&
        (_student.tenthPercentage ?? 0) < job.minTenthPercentage!) {
      return false;
    }

    if (job.minTwelfthPercentage != null &&
        (_student.twelfthPercentage ?? 0) < job.minTwelfthPercentage!) {
      return false;
    }

    if (!job.eligibleBranches.contains(_student.branch)) return false;

    if (job.requiredSkills.isNotEmpty) {
      final matchingSkills =
          _student.skills.where((s) => job.requiredSkills.contains(s)).length;
      if (matchingSkills == 0)
        return false; // Require at least one matching skill
    }

    if (job.requiresResume && (_student.resumePath ?? '').isEmpty) return false;

    return true;
  }

  List<JobModel> get eligibleJobs => _jobs.where(isEligibleForJob).toList();
  List<JobModel> get nonEligibleJobs =>
      _jobs.where((job) => !isEligibleForJob(job)).toList();

  // UPDATED: More detailed reason generation
  String getIneligibilityReason(JobModel job) {
    List<String> reasons = [];

    if (_student.cgpa < job.minCGPA) {
      reasons.add('CGPA: ${_student.cgpa.toStringAsFixed(2)} < ${job.minCGPA}');
    }

    if (job.minTenthPercentage != null &&
        (_student.tenthPercentage ?? 0) < job.minTenthPercentage!) {
      reasons.add(
          '10th: ${(_student.tenthPercentage ?? 0).toStringAsFixed(1)}% < ${job.minTenthPercentage}%');
    }

    if (job.minTwelfthPercentage != null &&
        (_student.twelfthPercentage ?? 0) < job.minTwelfthPercentage!) {
      reasons.add(
          '12th: ${(_student.twelfthPercentage ?? 0).toStringAsFixed(1)}% < ${job.minTwelfthPercentage}%');
    }

    if (!job.eligibleBranches.contains(_student.branch)) {
      reasons.add('Branch not eligible');
    }

    if (job.requiredSkills.isNotEmpty) {
      final matchingSkills =
          _student.skills.where((s) => job.requiredSkills.contains(s)).length;
      if (matchingSkills == 0) {
        reasons.add('Missing required skills');
      }
    }

    if (job.requiresResume && (_student.resumePath ?? '').isEmpty) {
      reasons.add('Resume required');
    }

    if (reasons.isEmpty) {
      return 'Check profile for missing data.';
    }

    return reasons.join(', ');
  }

  AptitudeTestResult? getAptitudeResult(String jobId) =>
      _aptitudeResults[jobId];

  void saveAptitudeResult(AptitudeTestResult result) {
    _aptitudeResults[result.jobId] = result;
    notifyListeners();
    _saveAptitudeResultToFirestore(result);
  }

  Future<void> _saveAptitudeResultToFirestore(AptitudeTestResult result) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('aptitudeResults')
          .doc(result.jobId)
          .set(result.toJson());
    } catch (e) {
      if (kDebugMode) print('Error saving aptitude result: $e');
    }
  }

  Future<void> loadAptitudeResults() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final snapshot = await _firestore
          .collection('students')
          .doc(user.uid)
          .collection('aptitudeResults')
          .get();
      for (var doc in snapshot.docs) {
        final result = AptitudeTestResult.fromJson(doc.data());
        _aptitudeResults[result.jobId] = result;
      }
    } catch (e) {
      if (kDebugMode) print('Error loading aptitude results: $e');
    }
    notifyListeners();
  }

  bool canApplyToJob(String jobId) {
    final result = getAptitudeResult(jobId);
    return result != null &&
        result.passed &&
        !_student.appliedJobIds.contains(jobId);
  }

  void applyToJob(String jobId) async {
    final newAppliedJobs = List<String>.from(_student.appliedJobIds)
      ..add(jobId);
    _student = _student.copyWith(appliedJobIds: newAppliedJobs);
    await saveStudent();
    notifyListeners();
  }
}
