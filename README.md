"SLRTCE Student Career Portal"
A comprehensive, cross-platform student portal application built with a hybrid backend of Flutter, Firebase, and Supabase. This app helps students manage their academic and professional profiles, find eligible job opportunities, take aptitude tests, and apply for jobs.

# Features
Firebase Authentication: Secure user registration and login system, with email verification required to upload files.

Interactive Dashboard: A central hub showing a personalized greeting, profile completion percentage, and key stats like CGPA and the number of eligible jobs.

Profile Management: Students can create and update their detailed profiles, including personal information, academic records, and professional skills.

Document Uploads: Securely upload and manage resumes and certificates to Supabase Storage. The app includes image compression to improve upload speed and save storage space.

# Job Portal:

View a list of job opportunities.

An automatic eligibility engine checks the student's profile (CGPA, branch, skills) against job requirements.

Jobs are sorted into 'Eligible' and 'Other' categories for clarity.

Aptitude Testing: For eligible jobs, students can take a built-in multiple-choice aptitude test. The app records the results and only allows applications after passing the test.

Alumni Showcase: A dedicated screen to display a list of successful alumni to inspire and inform current students.

# Tech Stack & Key Packages
Framework: Flutter

Backend: Hybrid (Firebase & Supabase)

Authentication: Firebase Authentication

Database: Cloud Firestore

File Storage: Supabase Storage
