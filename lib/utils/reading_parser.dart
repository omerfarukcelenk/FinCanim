Map<String, String> parseReadingIntoCategories(String src) {
  // Normalize newlines
  final text = src.replaceAll('\r\n', '\n');

  // Define ordered categories and their heading regex (case-insensitive).
  // Made colon optional to handle both "AŞK VE İLİŞKİLER:" and "AŞK VE İLİŞKİLER"
  final categories = <String, RegExp>{
    'genel': RegExp(r"(?:🔮\s*)?GENEL YORUM\s*:?\s*", caseSensitive: false),
    'ask': RegExp(r"(?:❤️\s*)?AŞK VE İLİŞKİLER\s*:?\s*", caseSensitive: false),
    'kariyer': RegExp(
      r"(?:💼\s*)?KARİYER VE İŞ(?:\s+HAYATI)?\s*:?\s*",
      caseSensitive: false,
    ),
    'gelecek': RegExp(
      r"(?:🌟\s*)?GELECEK VE FIRSATLAR\s*:?\s*",
      caseSensitive: false,
    ),
    'maddi': RegExp(
      r"(?:💰\s*)?MADD[Iİ]\s*DURUM\s*:?\s*",
      caseSensitive: false,
    ),
    'dikkat': RegExp(
      r"(?:⚠️\s*)?DİKKAT EDİLMESİ GEREKENLER\s*:?\s*",
      caseSensitive: false,
    ),
    'kapaniş': RegExp(r"(?:✨\s*)?KAPANIŞ MESAJI\s*:?\s*", caseSensitive: false),
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
    'kapaniş': '',
  };

  if (matches.isEmpty) {
    // If no headings found, treat whole text as 'genel'
    result['genel'] = text.trim();
    return result;
  }

  // Baslangic is text before first heading
  final first = matches.first;
  final beforeFirstHeading = text.substring(0, first.start).trim();

  // If first heading is NOT 'genel', intelligently split beforeFirstHeading:
  // - First paragraph goes to baslangic
  // - Remaining paragraphs go to genel
  if (first.key != 'genel' && beforeFirstHeading.isNotEmpty) {
    final paragraphs = beforeFirstHeading.split(RegExp(r'\n\s*\n+'));
    if (paragraphs.length > 1) {
      // Multiple paragraphs: keep first as baslangic, rest as genel
      result['baslangic'] = paragraphs.first.trim();
      result['genel'] = paragraphs.skip(1).join('\n\n').trim();
    } else {
      // Single paragraph: keep as baslangic
      result['baslangic'] = beforeFirstHeading;
    }
  } else {
    result['baslangic'] = beforeFirstHeading;
  }

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
