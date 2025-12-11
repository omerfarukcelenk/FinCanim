Map<String, String> parseReadingIntoCategories(String src) {
  // Normalize newlines
  final text = src.replaceAll('\r\n', '\n');

  // Define ordered categories and their heading regex (case-insensitive).
  final categories = <String, RegExp>{
    'genel': RegExp(r"(?:🔮\s*)?GENEL YORUM\s*:\s*", caseSensitive: false),
    'ask': RegExp(r"(?:❤️\s*)?AŞK VE İLİŞKİLER\s*:\s*", caseSensitive: false),
    'kariyer': RegExp(r"(?:💼\s*)?KARİYER VE İŞ\s*:\s*", caseSensitive: false),
    'gelecek': RegExp(
      r"(?:🌟\s*)?GELECEK VE FIRSATLAR\s*:\s*",
      caseSensitive: false,
    ),
    'maddi': RegExp(r"(?:💰\s*)?MADD[Iİ]\s*DURUM\s*:\s*", caseSensitive: false),
    'dikkat': RegExp(
      r"(?:⚠️\s*)?DİKKAT EDİLMESİ GEREKENLER\s*:\s*",
      caseSensitive: false,
    ),
  };

  // Find all heading matches with positions
  final matches = <_MatchPos>[];
  categories.forEach((key, rx) {
    final m = rx.firstMatch(text);
    if (m != null) matches.add(_MatchPos(key, m.start, m.end));
  });

  // Sort matches by position
  matches.sort((a, b) => a.start.compareTo(b.start));

  final result = <String, String>{
    'baslangic': '',
    'genel': '',
    'ask': '',
    'kariyer': '',
    'gelecek': '',
    'maddi': '',
    'dikkat': '',
  };

  if (matches.isEmpty) {
    // If no headings found, treat whole text as 'genel'
    result['genel'] = text.trim();
    return result;
  }

  // Baslangic is text before first heading
  final first = matches.first;
  result['baslangic'] = text.substring(0, first.start).trim();

  for (var i = 0; i < matches.length; i++) {
    final cur = matches[i];
    final startContent = cur.end;
    final endContent = (i + 1 < matches.length)
        ? matches[i + 1].start
        : text.length;
    final content = text.substring(startContent, endContent).trim();
    result[cur.key] = content;
  }

  return result;
}

class _MatchPos {
  final String key;
  final int start;
  final int end;
  _MatchPos(this.key, this.start, this.end);
}
