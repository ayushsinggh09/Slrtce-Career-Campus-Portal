import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, Uint8List;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../providers/student_provider.dart';

import '../services/supabase_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/file_utils.dart';
import '../widgets/section_header.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final SupabaseStorageService _storageService = SupabaseStorageService();
  bool _isUploading = false;
  String _uploadStatus = '';
  double? _uploadProgress = 0.0;

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    // FIX 1: Clear any previous snackbars before showing a new one.
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      duration: Duration(seconds: isError ? 4 : 2),
    ));
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickAndUpload(bool isResume) async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Waiting for file selection...';
      _uploadProgress = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: isResume
            ? AppConstants.resumeExtensions
            : AppConstants.certificateExtensions,
        allowMultiple: !isResume,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }

      final provider = Provider.of<StudentProvider>(context, listen: false);
      int fileCount = result.files.length;
      // FIX 2: Track if any uploads fail.
      bool anyUploadsFailed = false;

      for (int i = 0; i < fileCount; i++) {
        final file = result.files[i];

        setState(() {
          _uploadStatus = 'Processing ${file.name} (${i + 1}/$fileCount)...';
          _uploadProgress = null;
        });

        if (file.size > AppConstants.maxFileSize) {
          _showSnackBar('${file.name} exceeds 5MB limit', isError: true);
          anyUploadsFailed = true;
          continue;
        }

        Uint8List? initialBytes = kIsWeb
            ? file.bytes
            : (file.path != null ? await File(file.path!).readAsBytes() : null);

        if (initialBytes == null) {
          _showSnackBar('Failed to read ${file.name}', isError: true);
          anyUploadsFailed = true;
          continue;
        }

        Uint8List currentFileBytes = initialBytes;
        final extension = file.extension?.toLowerCase() ?? '';
        final isImage = ['jpg', 'jpeg', 'png'].contains(extension);

        if (isImage) {
          setState(() => _uploadStatus = 'Compressing ${file.name}...');
          try {
            currentFileBytes = await FlutterImageCompress.compressWithList(
              currentFileBytes,
              minHeight: 1280,
              minWidth: 1280,
              quality: 85,
            );
          } catch (e) {
            if (kDebugMode) print('Compression failed, using original: $e');
          }
        }

        setState(() {
          _uploadStatus = 'Uploading ${file.name}... (${i + 1}/$fileCount)';
          _uploadProgress = i / fileCount;
        });

        try {
          final downloadUrl = await _storageService.uploadFileFromBytes(
            bytes: currentFileBytes,
            folder: isResume ? 'resumes' : 'certificates',
            fileName: file.name,
            mimeType: _getMimeType(extension),
            onProgress: (progress) {
              if (mounted) {
                setState(() => _uploadProgress = (i + progress) / fileCount);
              }
            },
          );

          if (downloadUrl != null) {
            if (isResume) {
              await provider.updateResume(downloadUrl);
            } else {
              await provider.addCertificate(downloadUrl);
            }
          } else {
            anyUploadsFailed = true;
          }
        } catch (e) {
          _showSnackBar('Upload failed for ${file.name}', isError: true);
          anyUploadsFailed = true;
        }
      }

      // FIX 2: Only show the final success message if no errors occurred.
      if (!anyUploadsFailed) {
        _showSnackBar('Upload complete!');
      }
    } catch (e) {
      _showSnackBar('An error occurred: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteFile(String fileUrl, bool isResume) async {
    setState(() {
      _isUploading = true;
      _uploadStatus = 'Deleting file...';
      _uploadProgress = null;
    });

    try {
      await _storageService.deleteFile(fileUrl);
      final provider = Provider.of<StudentProvider>(context, listen: false);

      if (isResume) {
        await provider.updateResume(null);
      } else {
        await provider.removeCertificate(fileUrl);
      }

      _showSnackBar('File deleted successfully!');
    } catch (e) {
      _showSnackBar('Failed to delete file', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = Provider.of<StudentProvider>(context).student;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SectionHeader(
              title: 'Documents',
              subtitle: 'Manage your resume and certificates',
              icon: Icons.file_copy,
            ),
            const SizedBox(height: 20),
            if (_isUploading)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _uploadStatus,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isUploading) const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resume',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isUploading ? null : () => _pickAndUpload(true),
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(student.resumePath != null
                            ? 'Replace Resume'
                            : 'Upload Resume'),
                      ),
                    ),
                    if (student.resumePath != null) ...[
                      const SizedBox(height: 12),
                      _UploadedFileItem(
                        fileUrl: student.resumePath!,
                        onDelete: _isUploading
                            ? null
                            : () => _deleteFile(student.resumePath!, true),
                      ),
                    ],
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
                    const Text('Certificates',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isUploading ? null : () => _pickAndUpload(false),
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Add Certificates'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor),
                      ),
                    ),
                    if (student.certificatePaths.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No certificates uploaded yet',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ),
                      ),
                    if (student.certificatePaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...student.certificatePaths
                          .map((url) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _UploadedFileItem(
                                  fileUrl: url,
                                  onDelete: _isUploading
                                      ? null
                                      : () => _deleteFile(url, false),
                                ),
                              ))
                          .toList(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadedFileItem extends StatelessWidget {
  final String fileUrl;
  final VoidCallback? onDelete;
  const _UploadedFileItem({required this.fileUrl, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fileName = FileUtils.getFileName(fileUrl);
    final extension = FileUtils.getFileExtension(fileUrl);
    IconData fileIcon;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image;
        iconColor = Colors.green;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        iconColor = AppTheme.primaryColor;
    }

    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(fileIcon, color: iconColor, size: 32),
        title: Text(fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14)),
        subtitle: Text(extension.toUpperCase(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppTheme.errorColor),
          onPressed: onDelete,
          tooltip: 'Delete file',
        ),
      ),
    );
  }
}
