import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
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

  await for (final file in libFolder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      spinner.text = 'Extracting strings from ${file.path}...';
      try {
        final content = await file.readAsString();

        final trStrings = extractTrStrings(content);

        for (final trString in trStrings) {
          allEnglishTranslations[trString] = trString;
        }
      } catch (e) {
        spinner.warn('Error reading file: ${file.path}');
        print('Error reading file: ${file.path}');
      }
    }
  }

  spinner.success('Extracted ${allEnglishTranslations.length} strings!');
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
    await save('en', allEnglishStrings);
  } catch (e) {
    spinner.fail('Error: $e');
    exit(1);
  }
  spinner.success('Extracted ${allEnglishStrings.length} strings!');
}
