class SanitizationService {
  static const int maxNoteLength = 5000;
  static const int maxTitleLength = 100;

  static String sanitizeText(String input, {int maxLength = maxNoteLength}) {
    if (input.isEmpty) return input;

    // Remove control characters except standard whitespace (tab, LF, CR)
    String sanitized = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized.trim();
  }
}
