import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/section_header.dart';
import '../models/alumni_model.dart';

class AlumniScreen extends StatelessWidget {
  const AlumniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alumniList = AlumniModel.getSampleAlumni();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const SectionHeader(
              title: 'Our Alumni',
              subtitle: 'Celebrating the achievements of our graduates',
              icon: Icons.school,
            ),

            const SizedBox(height: 24),

            // Alumni Grid using LayoutBuilder for better responsiveness
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(constraints.maxWidth),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85, // Adjusted for content height
                  ),
                  itemCount: alumniList.length,
                  itemBuilder: (context, index) {
                    return _buildAlumniCard(alumniList[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Use available width from LayoutBuilder instead of global screen width
  int _getCrossAxisCount(double availableWidth) {
    if (availableWidth > 1200) return 5;
    if (availableWidth > 900) return 4;
    if (availableWidth > 600) return 3;
    if (availableWidth > 400) return 2;
    return 1;
  }

  Widget _buildAlumniCard(AlumniModel alumni) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.7),
                    AppTheme.secondaryColor.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: alumni.profileImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        alumni.profileImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(alumni.name),
                      ),
                    )
                  : _buildDefaultAvatar(alumni.name),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              alumni.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Restrict to one line for better card alignment
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Branch & Batch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${alumni.branch} - ${alumni.batch}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Current Position
            if (alumni.currentPosition.isNotEmpty)
              Flexible(
                child: Text(
                  alumni.currentPosition,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.successColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 4),

            // Company
            if (alumni.currentCompany.isNotEmpty)
              Flexible(
                child: Text(
                  alumni.currentCompany,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 12),

            // Achievements Section - Simplified for compact card
            if (alumni.achievements.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Top Achievements:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Show only the first achievement
                      "• ${alumni.achievements.first}",
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            
            // Added Spacer to push content up if no achievements
            if (alumni.achievements.isEmpty) const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}