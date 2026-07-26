/// Reusable form-field validators returning a localized-ready error string
/// (currently plain English; swap to AppLocalizations lookups if per-field
/// translated errors are required beyond the label translations already in
/// `app_en.arb`/`app_hi.arb`).
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$');
  static final RegExp _indianPhonePattern = RegExp(r'^[6-9]\d{9}$');

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? indianPhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    if (!_indianPhonePattern.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Add at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Add at least one lowercase letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Add at least one number';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) return 'Enter the OTP';
    if (value.trim().length != length || !RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'Enter a valid $length-digit code';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final parsed = num.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return '$fieldName must be a positive number';
    return null;
  }
}
