import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/welcome_card.dart';
import '../widgets/stats_cards.dart';
import '../widgets/navigation_menu.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final List<String> _screenTitles = const [
    'Dashboard',
    'Profile Details',
    'Academic Records',
    'Documents',
    'Job Opportunities',
    'Our Alumni',
  ];

  void _onIndexChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Widget currentScreen() {
      if (_selectedIndex == 0) {
        // Pass the navigation callback to the dashboard content
        return _buildDashboardContent(_onIndexChanged);
      }
      return NavigationMenu(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onIndexChanged,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: currentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onIndexChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.grade), label: 'Academic'),
          BottomNavigationBarItem(icon: Icon(Icons.file_copy), label: 'Docs'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Alumni'),
        ],
      ),
    );
  }

  // MODIFIED: This widget now builds the entire enhanced dashboard
  Widget _buildDashboardContent(void Function(int) navigateToTab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeCard(),
          const SizedBox(height: 20),
          const StatsCards(),
          const SizedBox(height: 20),

          // NEW WIDGET 1: Profile Checklist Card
          _buildProgressCard(),
          const SizedBox(height: 20),

          // NEW WIDGET 2: Quick Actions Card
          _buildQuickActionsCard(navigateToTab),
          const SizedBox(height: 20),

          // NEW WIDGET 3: Eligible Jobs Quick View Card
          _buildJobQuickViewCard(navigateToTab),
        ],
      ),
    );
  }

  // NEW HELPER WIDGET: For the Profile Checklist
  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<StudentProvider>(
              builder: (context, provider, child) {
                final student = provider.student;
                return Column(
                  children: [
                    _buildProgressItem(
                      'Basic Details Complete',
                      student.name.isNotEmpty && student.phone.isNotEmpty,
                      Icons.person,
                    ),
                    _buildProgressItem(
                      'Academic Records Added',
                      student.tenthPercentage != null &&
                          student.twelfthPercentage != null,
                      Icons.school,
                    ),
                    _buildProgressItem(
                      'Resume Uploaded',
                      student.resumePath != null &&
                          student.resumePath!.isNotEmpty,
                      Icons.description,
                    ),
                    _buildProgressItem(
                      'Skills Added',
                      student.skills.isNotEmpty,
                      Icons.lightbulb,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // NEW HELPER WIDGET: For the individual checklist items
  Widget _buildProgressItem(String title, bool isCompleted, IconData icon) {
    final color = isCompleted ? AppTheme.successColor : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: color, size: 20),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.black87 : Colors.grey[600],
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW HELPER WIDGET: For the Quick Actions buttons
  Widget _buildQuickActionsCard(void Function(int) navigateToTab) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => navigateToTab(1), // Go to Profile
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => navigateToTab(3), // Go to Documents
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Doc'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // NEW HELPER WIDGET: For the Eligible Jobs preview
  Widget _buildJobQuickViewCard(void Function(int) navigateToTab) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        final eligibleJobs = provider.eligibleJobs;
        if (eligibleJobs.isEmpty) {
          return const SizedBox.shrink(); // Don't show anything if no jobs
        }
        return Card(
          color: AppTheme.successColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work, color: AppTheme.successColor),
                    const SizedBox(width: 8),
                    Text(
                      'You\'re Eligible for ${eligibleJobs.length} Job(s)!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Great news! Based on your profile, you can apply for ${eligibleJobs.length} job opportunities right now.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => navigateToTab(4), // Go to Jobs
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor),
                    child: const Text('View Job Opportunities'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
