import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';

class AptitudeTestScreen extends StatefulWidget {
  final JobModel job;
  const AptitudeTestScreen({super.key, required this.job});

  @override
  State<AptitudeTestScreen> createState() => _AptitudeTestScreenState();
}

class _AptitudeTestScreenState extends State<AptitudeTestScreen> {
  int _currentQuestionIndex = 0;
  late List<int?> _selectedAnswers;
  bool _testCompleted = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.job.aptitudeQuestions.length, null);
  }

  void _submitTest() {
    int correctAnswers = 0;
    for (int i = 0; i < widget.job.aptitudeQuestions.length; i++) {
      if (_selectedAnswers[i] == widget.job.aptitudeQuestions[i].correctAnswer) {
        correctAnswers++;
      }
    }

    final result = AptitudeTestResult(
      jobId: widget.job.id,
      totalQuestions: widget.job.aptitudeQuestions.length,
      correctAnswers: correctAnswers,
      passed: correctAnswers >= 2, // Assuming 2 correct answers to pass
      completedAt: DateTime.now(),
    );

    Provider.of<StudentProvider>(context, listen: false).saveAptitudeResult(result);
    setState(() => _testCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_testCompleted) {
      return _buildResultsScreen();
    }
    return _buildTestScreen();
  }

  Scaffold _buildTestScreen() {
    final question = widget.job.aptitudeQuestions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_currentQuestionIndex + 1}/${widget.job.aptitudeQuestions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              return RadioListTile<int>(
                title: Text(question.options[index]),
                value: index,
                groupValue: _selectedAnswers[_currentQuestionIndex],
                onChanged: (value) => setState(() => _selectedAnswers[_currentQuestionIndex] = value),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    child: const Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: _selectedAnswers[_currentQuestionIndex] == null
                      ? null
                      : () {
                    if (_currentQuestionIndex < widget.job.aptitudeQuestions.length - 1) {
                      setState(() => _currentQuestionIndex++);
                    } else {
                      _submitTest();
                    }
                  },
                  child: Text(_currentQuestionIndex < widget.job.aptitudeQuestions.length - 1 ? 'Next' : 'Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildResultsScreen() {
    final result = Provider.of<StudentProvider>(context, listen: false).getAptitudeResult(widget.job.id)!;
    return Scaffold(
      appBar: AppBar(title: const Text('Test Results'), automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result.passed ? 'Congratulations, you passed!' : 'Sorry, you did not pass.', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Your score: ${result.correctAnswers} / ${result.totalQuestions}'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to Jobs'),
            ),
          ],
        ),
      ),
    );
  }
}