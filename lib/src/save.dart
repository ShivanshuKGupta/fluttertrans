import 'dart:io';

import 'package:fluttertrans/src/globals.dart';

/// Function to save translations to a file
Future<void> save(
    String languageCode, Map<String, String?> translations) async {
  final langFile = File('${assetFolder.path}/$languageCode.json');
  String prettyPrint = prettyJson.convert(translations);
  await langFile.writeAsString(prettyPrint);
}
