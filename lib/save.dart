import 'dart:convert';
import 'dart:io';

import 'package:fluttertrans/globals.dart';

/// Function to save translations to a file
Future<void> save(
    String languageCode, Map<String, String?> translations) async {
  final langFile = File('${assetFolder.path}/$languageCode.json');
  await langFile.writeAsString(json.encode(translations));
}
