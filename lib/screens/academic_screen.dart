import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/section_header.dart';

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _semesterControllers;
  late TextEditingController _tenthController;
  late TextEditingController _twelfthController;
  late TextEditingController _diplomaController;

  @override
  void initState() {
    super.initState();
    final student = Provider.of<StudentProvider>(context, listen: false).student;
    _tenthController = TextEditingController(text: student.tenthPercentage?.toString() ?? '');
    _twelfthController = TextEditingController(text: student.twelfthPercentage?.toString() ?? '');
    _diplomaController = TextEditingController(text: student.diplomaPercentage?.toString() ?? '');
    _semesterControllers = List.generate(8, (i) => TextEditingController(text: student.semesterGPAs[i]?.toString() ?? ''));
  }

  @override
  void dispose() {
    _tenthController.dispose();
    _twelfthController.dispose();
    _diplomaController.dispose();
    for (var controller in _semesterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveAcademicDetails() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<StudentProvider>(context, listen: false);
      provider.updateAcademicDetails(
        tenthPercentage: double.tryParse(_tenthController.text),
        twelfthPercentage: double.tryParse(_twelfthController.text),
        diplomaPercentage: _diplomaController.text.isEmpty ? null : double.tryParse(_diplomaController.text),
      );
      for (int i = 0; i < 8; i++) {
        provider.updateSemesterGPA(i + 1, double.tryParse(_semesterControllers[i].text));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.academicDetailsSavedMessage),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
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
                title: 'Academic Records',
                subtitle: 'Enter your school and college performance',
                icon: Icons.grade,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _tenthController,
                        labelText: '10th Percentage *',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validatePercentage(v, fieldName: '10th'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _twelfthController,
                        labelText: '12th Percentage *',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: (v) => Validators.validatePercentage(v, fieldName: '12th'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _diplomaController,
                        labelText: 'Diploma Percentage (Optional)',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: Validators.validateOptionalPercentage,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Semester GPAs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...List.generate(4, (rowIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _semesterControllers[rowIndex * 2],
                                  labelText: 'Sem ${rowIndex * 2 + 1} GPA',
                                  keyboardType: TextInputType.number,
                                  validator: Validators.validateGPA,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextField(
                                  controller: _semesterControllers[rowIndex * 2 + 1],
                                  labelText: 'Sem ${rowIndex * 2 + 2} GPA',
                                  keyboardType: TextInputType.number,
                                  validator: Validators.validateGPA,
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAcademicDetails,
                  child: const Text('Save Academic Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}