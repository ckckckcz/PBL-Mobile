/// Form validation utility functions
/// Centralized validation logic for forms
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Email validation
  /// Returns error message if invalid, null if valid
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// Password validation
  /// Returns error message if invalid, null if valid
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < minLength) {
      return 'Password minimal $minLength karakter';
    }

    return null;
  }

  /// Confirm password validation
  /// Returns error message if invalid, null if valid
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }

    if (value != originalPassword) {
      return 'Password tidak cocok';
    }

    return null;
  }

  /// Name validation
  /// Returns error message if invalid, null if valid
  static String? name(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return 'Nama harus diisi';
    }

    if (value.length < minLength) {
      return 'Nama minimal $minLength karakter';
    }

    // Check if contains only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf';
    }

    return null;
  }

  /// Phone number validation
  /// Returns error message if invalid, null if valid
  static String? phone(String? value, {bool required = false}) {
    if (!required && (value == null || value.isEmpty)) {
      return null; // Optional field
    }

    if (required && (value == null || value.isEmpty)) {
      return 'Nomor telepon harus diisi';
    }

    // Remove non-digit characters
    final cleaned = value!.replaceAll(RegExp(r'\D'), '');

    // Check length (Indonesian phone numbers)
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Nomor telepon tidak valid';
    }

    // Check if starts with valid prefix
    if (!cleaned.startsWith('0') && !cleaned.startsWith('62')) {
      return 'Nomor telepon harus diawali 0 atau 62';
    }

    return null;
  }

  /// Required field validation
  /// Returns error message if empty, null if valid
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  /// Min length validation
  /// Returns error message if too short, null if valid
  static String? minLength(String? value, int length,
      {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null; // Use required() for empty check
    }

    if (value.length < length) {
      return '$fieldName minimal $length karakter';
    }

    return null;
  }

  /// Max length validation
  /// Returns error message if too long, null if valid
  static String? maxLength(String? value, int length,
      {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > length) {
      return '$fieldName maksimal $length karakter';
    }

    return null;
  }

  /// Numeric validation
  /// Returns error message if not numeric, null if valid
  static String? numeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }

    return null;
  }

  /// URL validation
  /// Returns error message if invalid URL, null if valid
  static String? url(String? value, {bool required = false}) {
    if (!required && (value == null || value.isEmpty)) {
      return null;
    }

    if (required && (value == null || value.isEmpty)) {
      return 'URL harus diisi';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value!)) {
      return 'Format URL tidak valid';
    }

    return null;
  }

  /// Compose multiple validators
  /// Returns first error message found, null if all valid
  static String? compose(List<String? Function()> validators) {
    for (final validator in validators) {
      final error = validator();
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
