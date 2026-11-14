class OfflineSummarizer {
  OfflineSummarizer._();

  /// Port 1:1 dari `summarizeOffline` di App.js:
  /// Mengambil hingga tiga kalimat pertama (maks. 1.200 karakter). Bukan AI.
  static String? summarizeFirstThreeSentences(String sourceText) {
    final cleaned = sourceText.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return null;
    final matches = RegExp(r'[^.!?]+[.!?]?')
        .allMatches(cleaned)
        .map((m) => (m.group(0) ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final sentences = matches.isNotEmpty ? matches : <String>[cleaned];
    final joined = sentences.take(3).join(' ');
    return joined.length > 1200 ? joined.substring(0, 1200) : joined;
  }
}
