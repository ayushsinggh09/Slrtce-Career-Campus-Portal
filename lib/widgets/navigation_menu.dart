import 'package:flutter/material.dart';
import '../screens/academic_screen.dart';
import '../screens/documents_screen.dart';
import '../screens/job_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/alumni_screen.dart';

class NavigationMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const NavigationMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screens = [
      Container(), 
      const ProfileScreen(),
      const AcademicScreen(),
      const DocumentsScreen(),
      const JobsScreen(),
      const AlumniScreen(),
    ];

    if (selectedIndex < 0 || selectedIndex >= screens.length) {// for dashboard as it start for index 0
      return Container(); // Fallback for an invalid index
    }

    return IndexedStack(index: selectedIndex, children: screens);
  }
}