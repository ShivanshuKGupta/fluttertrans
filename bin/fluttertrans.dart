import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:translator/translator.dart';

late final String baseDir;
final translator = GoogleTranslator();

Directory get libFolder => Directory('$baseDir/lib');
Directory get assetFolder => Directory('$baseDir/assets/translations');
File get localesFile => File('${assetFolder.path}/all_locales.json');

void main(List<String> arguments) async {
  if (arguments.firstOrNull == '--help' || arguments.firstOrNull == '-h') {
    print('Usage: fluttertrans [project_dir]');
    exit(0);
  }

  CliSpin spinner = CliSpin(
    text: 'Extracting strings...',
    spinner: CliSpinners.line,
  ).start();

  baseDir = arguments.firstOrNull ?? Directory.current.absolute.path;
  dynamic allLocales = <String>[];

  try {
    if (!await assetFolder.exists()) {
      await assetFolder.create(recursive: true);
    }

    if (!await localesFile.exists()) {
      localesFile.writeAsStringSync('[]');
    }

    allLocales = json.decode(await localesFile.readAsString());

    if (allLocales.isEmpty) {
      throw 'Please add some locales to `${localesFile.path}`\nAnd then try again.';
    }

    if (allLocales! is List<String>) {
      throw 'Invalid locales file data. Please make sure it is a list of strings.';
    }
  } catch (e) {
    spinner.fail('Error: $e');
    exit(1);
  }

  final Map<String, String?> allEnglishStrings = {};

  await for (final file in libFolder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      spinner.text = 'Extracting strings from ${file.path}...';
      try {
        final content = await file.readAsString();
        final trStrings = extractTrStrings(content);

        for (final trString in trStrings) {
          allEnglishStrings[trString] = null;
        }
      } catch (e) {
        spinner.warn('Error reading file: ${file.path}');
        print('Error reading file: ${file.path}');
      }
    }
  }

  try {
    await save('en', allEnglishStrings);
  } catch (e) {
    spinner.fail('Error: $e');
    exit(1);
  }
  spinner.success('Extracted ${allEnglishStrings.length} strings!');

  for (final languageCode in allLocales) {
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

  spinner.success('All translations done!');

  spinner = CliSpin(
    text: 'Running flutter pub get...',
    spinner: CliSpinners.line,
  ).start();

  try {
    final result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: baseDir,
    );

    if (result.exitCode != 0) {
      spinner.fail('Error running flutter pub get');
      print(result.stderr);
      exit(1);
    }

    spinner.success('flutter pub get done!');
  } catch (e) {
    spinner.fail('Error running flutter pub get: $e');
    exit(1);
  }
}

Future<void> translateNSave(
    String languageCode, Map<String, String?> allEnglishStrings) async {
  final Map<String, String?> trStrings = {};

  final langFile = File('${assetFolder.path}/$languageCode.json');

  if (await langFile.exists()) {
    final content = await langFile.readAsString();
    final translations = (json.decode(content) as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as String?));

    trStrings.addAll(translations);
  }

  for (final englishString in allEnglishStrings.keys) {
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
      final translation = await translator.translate(
        englishString,
        from: 'en',
        to: languageCode,
      );

      trStrings[englishString] = translation.text;
      spinner.success(
          'Translated \'$englishString\' to $languageCode: \'${translation.text}\'');
    } catch (e) {
      spinner.fail('Error translating $englishString to $languageCode: $e');

      trStrings[englishString] = null;
    }
  }

  await save(languageCode, trStrings);
}

List<String> extractTrStrings(String content) {
  final regExp = RegExp(r'''["'](.*?)["']\s*\.tr''', multiLine: true);

  final matches = regExp.allMatches(content);
  final trStrings = matches.map((match) => match.group(1)!).toList();

  return trStrings;
}

Future<void> save(
    String languageCode, Map<String, String?> translations) async {
  final langFile = File('${assetFolder.path}/$languageCode.json');
  await langFile.writeAsString(json.encode(translations));
}
