/// Function to extract translation strings from the Dart file content
List<String> extractTrStrings(String content) {
  final regExp = RegExp(r'''["'](.*?)["']\s*\.tr''', multiLine: true);

  final matches = regExp.allMatches(content);
  final trStrings = matches.map((match) => match.group(1)!).toList();

  return trStrings;
}
