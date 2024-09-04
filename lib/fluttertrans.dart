import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:fluttertrans/src/console_utils.dart';
import 'package:fluttertrans/src/extract_all_strings.dart';
import 'package:fluttertrans/src/extractor_tr_strings.dart';
import 'package:fluttertrans/src/flutter_pub_get.dart';
import 'package:fluttertrans/src/get_supported_locales.dart';
import 'package:fluttertrans/src/globals.dart';
import 'package:fluttertrans/src/save.dart';
import 'package:fluttertrans/src/translate_save.dart';

Future<void> main(List<String> arguments) async {
  baseDir = arguments.firstOrNull ?? Directory.current.absolute.path;

  final supportedLocales = await getSupportedLocales();

  final allEnglishTranslations = await extractStrings();

  await saveEnglishTranslations(allEnglishTranslations);

  await translateOtherLanguages(
      supportedLocales.cast<String>(), allEnglishTranslations);

  await flutterPubGet();
}

Future<Map<String, String?>> extractStrings() async {
  final spinner = CliSpin(
    text: 'Extracting strings...',
    spinner: CliSpinners.line,
  ).start();

  final Map<String, String?> allEnglishTranslations = {};

  final langFile = File('${assetFolder.path}/en.json');

  /// Load existing translations if the file exists
  if (await langFile.exists()) {
    final content = await langFile.readAsString();
    final translations = (json.decode(content) as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as String?));

    allEnglishTranslations.addAll(translations);
  }

  final trStrings = [];
  final simpleStrings = [];
  final adjacentStrings = [];
  final interpolatedStrings = [];

  await for (final file in libFolder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      spinner.text = 'Extracting strings from ${file.path}...';
      try {
        final content = await file.readAsString();
        final collection = extractAllStrings(content);

        trStrings.addAll(extractTrStrings(content));
        simpleStrings.addAll(collection.simpleStrings);
        adjacentStrings.addAll(collection.adjacentStrings);
        interpolatedStrings.addAll(collection.interpolatedStrings);
      } catch (e) {
        spinner.warn('Error reading file: ${file.path}');
        print('Error reading file: ${file.path}');
      }
    }

    for (final trString in trStrings) {
      if (allEnglishTranslations.containsKey(trString)) continue;
      allEnglishTranslations[trString] = trString;
    }

    for (final x in simpleStrings) {
      if (allEnglishTranslations.containsKey(x)) continue;
      allEnglishTranslations[x] = null;
    }

    for (final x in adjacentStrings) {
      if (allEnglishTranslations.containsKey(x)) continue;
      allEnglishTranslations[x] = null;
    }

    for (final x in interpolatedStrings) {
      if (allEnglishTranslations.containsKey(x)) continue;
      allEnglishTranslations[x] = null;
    }
  }

  spinner.success('Extracted ${allEnglishTranslations.length} strings!');

  final toInclude = chooseMany(
    allEnglishTranslations.keys.toList(),
    prompt: 'Which strings to translate?',
    initialSelections: allEnglishTranslations.keys
        .where((key) => allEnglishTranslations[key] != null)
        .toSet(),
  );

  allEnglishTranslations.forEach((key, value) {
    allEnglishTranslations[key] = toInclude.contains(key) ? key : null;
  });

  return allEnglishTranslations;
}

Future<void> translateOtherLanguages(List<String> supportedLocales,
    Map<String, String?> allEnglishStrings) async {
  for (final languageCode in supportedLocales) {
    if (languageCode == 'en') {
      continue;
    }

    final spinner = CliSpin(
      text: 'Translating to $languageCode...',
      spinner: CliSpinners.line,
    ).start();

    try {
      await translateNSave(languageCode.toString(), allEnglishStrings);
      spinner.success(
          'Saved $languageCode translations to ${assetFolder.path}/$languageCode.json!');
    } catch (e) {
      spinner.fail('Error Translating to $languageCode: $e');
    }
  }
}

Future<void> saveEnglishTranslations(
    Map<String, String?> allEnglishStrings) async {
  final spinner = CliSpin(
    text: 'Saving strings...',
    spinner: CliSpinners.line,
  ).start();
  try {
    final Map<String, String?> data = {
      for (final key in allEnglishStrings.keys)
        if (allEnglishStrings[key] != null) key: allEnglishStrings[key],
      for (final key in allEnglishStrings.keys)
        if (allEnglishStrings[key] == null) key: allEnglishStrings[key]
    };
    await save('en', data);
  } catch (e) {
    spinner.fail('Error: $e');
    exit(1);
  }
  spinner.success('Extracted ${allEnglishStrings.length} strings!');
}
