import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:fluttertrans/src/globals.dart';
import 'package:fluttertrans/src/save.dart';

/// Function to translate strings and save the translations
Future<void> translateNSave(
    String languageCode, Map<String, String?> allEnglishStrings) async {
  final Map<String, String?> trStrings = {};

  final langFile = File('${assetFolder.path}/$languageCode.json');

  /// Load existing translations if the file exists
  if (await langFile.exists()) {
    final content = await langFile.readAsString();
    final translations = (json.decode(content) as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as String?));

    trStrings.addAll(translations);
  }

  /// Translate each English string
  for (final englishString in allEnglishStrings.keys.where(
    (element) => allEnglishStrings[element] != null,
  )) {
    if (trStrings.containsKey(englishString) &&
        trStrings[englishString] != null) {
      continue;
    }

    final spinner = CliSpin(
      text: 'Translating $englishString...',
      spinner: CliSpinners.line,
      indent: 2,
    ).start();

    try {
      /// Use Google Translator API to translate the string
      final translation = await translator.translate(
        englishString,
        from: 'en',
        to: languageCode,
      );

      trStrings[englishString] = translation.text;
      spinner.success(
          'Translated \'$englishString\' to $languageCode: \'${translation.text}\'');
    } catch (e) {
      /// Handle errors in translating the string
      spinner.fail('Error translating $englishString to $languageCode: $e');

      trStrings[englishString] = null;
    }
  }

  /// Save the translations to a file
  await save(languageCode, trStrings);
}
