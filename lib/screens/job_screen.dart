import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import 'aptitude_test_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final eligibleJobs = provider.eligibleJobs;
    final nonEligibleJobs = provider.nonEligibleJobs;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SectionHeader(
                title: 'Job Opportunities',
                subtitle: 'Find jobs that match your profile',
                icon: Icons.work,
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Eligible Jobs'),
                Tab(text: 'Other Jobs'),
              ],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildJobList(context, eligibleJobs, true),
                  _buildJobList(context, nonEligibleJobs, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(BuildContext context, List<JobModel> jobs, bool isEligible) {
    if (jobs.isEmpty) {
      return Center(child: Text('No jobs available in this category.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return _JobCard(job: jobs[index], isEligible: isEligible);
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  final bool isEligible;
  const _JobCard({required this.job, required this.isEligible});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StudentProvider>(context);
    final student = provider.student;
    final hasApplied = student.appliedJobIds.contains(job.id);
    final aptitudeResult = provider.getAptitudeResult(job.id);
    final canApply = provider.canApplyToJob(job.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(job.company, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(job.description, style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 24),
            Text('Minimum CGPA: ${job.minCGPA}', style: TextStyle(color: Colors.grey[600])),
            if(!isEligible) ...[
              const SizedBox(height: 8),
              Text('Reason: ${provider.getIneligibilityReason(job)}', style: const TextStyle(color: AppTheme.errorColor, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            if (isEligible && !hasApplied)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (aptitudeResult == null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AptitudeTestScreen(job: job),
                        ));
                      },
                      child: const Text('Take Aptitude Test'),
                    ),
                  if (canApply)
                    ElevatedButton(
                      onPressed: () {
                        provider.applyToJob(job.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Successfully applied!'),
                          backgroundColor: AppTheme.successColor,
                        ));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                      child: const Text('Apply Now'),
                    ),
                ],
              ),
            if (hasApplied) const Text('Applied', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}