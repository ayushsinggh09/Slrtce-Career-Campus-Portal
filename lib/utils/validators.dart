class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your roll number';
    }
    return null;
  }

  static String? validatePercentage(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName percentage';
    }
    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Please enter a valid number';
    }
    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }

  static String? validateOptionalPercentage(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Please enter a valid number';
    }
    if (percentage < 0 || percentage > 100) {
      return 'Percentage must be between 0 and 100';
    }
    return null;
  }

  static String? validateGPA(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final gpa = double.tryParse(value);
    if (gpa == null) {
      return 'Please enter a valid GPA';
    }
    if (gpa < 0 || gpa > 10) {
      return 'GPA must be between 0 and 10';
    }
    return null;
  }

  static String? validateDropdown(String? value, {required String fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Please select your $fieldName';
    }
    return null;
  }
}