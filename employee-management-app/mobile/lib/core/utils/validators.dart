class Validators {
  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;

  static String? emailOrEmployee(String? value) =>
      required(value, 'Employee ID / Email');
}
