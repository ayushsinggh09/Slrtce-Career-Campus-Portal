import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../providers/student_provider.dart';
import '../services/supabase_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _rollNumberController;
  late TextEditingController _skillController;

  String _selectedBranch = '';
  String _selectedBatchYear = '';
  List<String> _skills = [];
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final SupabaseStorageService _storageService = SupabaseStorageService();

  final List<String> _allSkillSuggestions = [
    ...AppConstants.technicalSkills,
    ...AppConstants.softSkills,
    ...AppConstants.designSkills,
  ]..sort();

  @override
  void initState() {
    super.initState();
    final student =
        Provider.of<StudentProvider>(context, listen: false).student;
    _nameController = TextEditingController(text: student.name);
    _emailController = TextEditingController(text: student.email);
    _phoneController = TextEditingController(text: student.phone);
    _rollNumberController = TextEditingController(text: student.rollNumber);
    _skillController = TextEditingController();
    _selectedBranch = student.branch;
    _selectedBatchYear = student.batchYear;
    _skills = List.from(student.skills);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollNumberController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      await provider.updateBasicDetails(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        rollNumber: _rollNumberController.text.trim(),
        branch: _selectedBranch,
        batchYear: _selectedBatchYear,
      );
      await provider.updateSkills(_skills);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.profileSavedMessage),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    setState(() => _isUploadingImage = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploadingImage = false);
        return;
      }

      final file = result.files.first;
      if (file.size > AppConstants.maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image exceeds 5MB limit'),
            backgroundColor: AppTheme.errorColor));
        setState(() => _isUploadingImage = false);
        return;
      }

      Uint8List? fileBytes = kIsWeb
          ? file.bytes
          : (file.path != null ? await File(file.path!).readAsBytes() : null);

      if (fileBytes == null) {
        setState(() => _isUploadingImage = false);
        return;
      }

      Uint8List currentFileBytes = fileBytes;
      final extension = file.extension?.toLowerCase() ?? 'jpg';

      // Compress image
      try {
        currentFileBytes = await FlutterImageCompress.compressWithList(
          fileBytes,
          minHeight: 512,
          minWidth: 512,
          quality: 85,
        );
        if (kDebugMode) print('Image compressed successfully');
      } catch (e) {
        if (kDebugMode) print('Compression failed, using original: $e');
      }

      // Upload to Firebase
      final downloadUrl = await _storageService.uploadFileFromBytes(
        bytes: currentFileBytes,
        folder: 'profile_pictures',
        fileName: file.name,
        mimeType: _getMimeType(extension),
      );

      if (kDebugMode) print('Upload complete. URL: $downloadUrl');

      if (downloadUrl != null && mounted) {
        await Provider.of<StudentProvider>(context, listen: false)
            .updateProfilePicture(downloadUrl);

        if (kDebugMode) print('Profile picture updated in provider');

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: AppTheme.successColor));
      }
    } catch (e) {
      if (kDebugMode) print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload image: $e'),
            backgroundColor: AppTheme.errorColor));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _addSkillFromSuggestion(String skill) {
    if (!_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  List<String> _getFilteredSuggestions() {
    final query = _skillController.text.toLowerCase();
    if (query.isEmpty) return [];
    return _allSkillSuggestions
        .where((skill) =>
            skill.toLowerCase().contains(query) && !_skills.contains(skill))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SectionHeader(
                title: 'Profile Details',
                subtitle: 'Keep your personal and academic info up to date',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Consumer<StudentProvider>(
                        builder: (context, provider, child) {
                          final imageUrl = provider.student.profilePicturePath;
                          if (kDebugMode)
                            print('Rendering profile image. URL: $imageUrl');

                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            child: imageUrl != null && imageUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        if (kDebugMode)
                                          print('Image load error: $error');
                                        return const Icon(Icons.person,
                                            size: 60, color: Colors.grey);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 60, color: Colors.grey),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isUploadingImage
                            ? null
                            : _pickAndUploadProfileImage,
                        icon: _isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.camera_alt_outlined),
                        label: Text(_isUploadingImage
                            ? 'Uploading...'
                            : 'Change Picture'),
                      ),
                      // Debug button - remove in production
                      if (kDebugMode)
                        Consumer<StudentProvider>(
                          builder: (context, provider, child) {
                            final imageUrl =
                                provider.student.profilePicturePath;
                            if (imageUrl != null && imageUrl.isNotEmpty) {
                              return TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Test Image'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.network(imageUrl),
                                          const SizedBox(height: 8),
                                          SelectableText(imageUrl,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text('Test Image Load'),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'College Email',
                        prefixIcon: Icons.email_outlined,
                        enabled: false,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Full Name *',
                        prefixIcon: Icons.person_outline,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number *',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _rollNumberController,
                        labelText: 'Roll Number *',
                        prefixIcon: Icons.badge_outlined,
                        validator: Validators.validateRollNumber,
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown(
                        value:
                            _selectedBranch.isNotEmpty ? _selectedBranch : null,
                        labelText: 'Branch *',
                        prefixIcon: Icons.engineering_outlined,
                        items: AppConstants.branches,
                        onChanged: (value) =>
                            setState(() => _selectedBranch = value ?? ''),
                        validator: (value) => Validators.validateDropdown(value,
                            fieldName: 'Branch'),
                      ),
                      const SizedBox(height: 16),
                      CustomDropdown(
                        value: _selectedBatchYear.isNotEmpty
                            ? _selectedBatchYear
                            : null,
                        labelText: 'Batch Year *',
                        prefixIcon: Icons.calendar_today_outlined,
                        items: AppConstants.batchYears,
                        onChanged: (value) =>
                            setState(() => _selectedBatchYear = value ?? ''),
                        validator: (value) => Validators.validateDropdown(value,
                            fieldName: 'Batch Year'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Skills',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _skillController,
                              labelText: 'Add a skill (e.g., Java)',
                              onChanged: (value) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: AppTheme.primaryColor),
                            onPressed: _addSkill,
                          ),
                        ],
                      ),
                      if (_getFilteredSuggestions().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _getFilteredSuggestions()
                              .map((skill) => ActionChip(
                                    label: Text(skill),
                                    onPressed: () =>
                                        _addSkillFromSuggestion(skill),
                                  ))
                              .toList(),
                        )
                      ],
                      const SizedBox(height: 16),
                      if (_skills.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: _skills
                              .map((skill) => Chip(
                                    label: Text(skill),
                                    onDeleted: () => _removeSkill(skill),
                                    deleteIconColor: AppTheme.errorColor,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
