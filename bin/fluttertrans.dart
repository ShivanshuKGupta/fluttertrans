import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:translator/translator.dart';

// Global variables and constants
late final String baseDir;
final translator = GoogleTranslator();

// Getter for the lib folder in the project
Directory get libFolder => Directory('$baseDir/lib');
// Getter for the assets/translations folder
Directory get assetFolder => Directory('$baseDir/assets/translations');
// Getter for the locales file in the assets/translations folder
File get localesFile => File('${assetFolder.path}/all_locales.json');

// Main entry point of the script
void main(List<String> arguments) async {
  // Show help message if --help or -h argument is passed
  if (arguments.firstOrNull == '--help' || arguments.firstOrNull == '-h') {
    print('Usage: fluttertrans [project_dir]');
    exit(0);
  }

  // Initialize a spinner to indicate progress
  CliSpin spinner = CliSpin(
    text: 'Extracting strings...',
    spinner: CliSpinners.line,
  ).start();

  // Set the base directory to the provided argument or current directory
  baseDir = arguments.firstOrNull ?? Directory.current.absolute.path;
  dynamic allLocales = <String>[];

  try {
    // Ensure the asset folder exists
    if (!await assetFolder.exists()) {
      await assetFolder.create(recursive: true);
    }

    // Ensure the locales file exists
    if (!await localesFile.exists()) {
      localesFile.writeAsStringSync('[]');
    }

    // Read and parse the locales file
    allLocales = json.decode(await localesFile.readAsString());

    // Validate the locales data
    if (allLocales.isEmpty) {
      throw 'Please add some locales to `${localesFile.path}`\nAnd then try again.';
    }

    if (allLocales! is List<String>) {
      throw 'Invalid locales file data. Please make sure it is a list of strings.';
    }
  } catch (e) {
    // Handle errors in setting up the asset folder and locales file
    spinner.fail('Error: $e');
    exit(1);
  }

  // Initialize a map to store all English strings
  final Map<String, String?> allEnglishStrings = {};

  // Iterate over all Dart files in the lib folder
  await for (final file in libFolder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      spinner.text = 'Extracting strings from ${file.path}...';
      try {
        // Read the file content
        final content = await file.readAsString();
        // Extract translation strings from the content
        final trStrings = extractTrStrings(content);

        // Add the extracted strings to the map
        for (final trString in trStrings) {
          allEnglishStrings[trString] = null;
        }
      } catch (e) {
        // Handle errors in reading the file
        spinner.warn('Error reading file: ${file.path}');
        print('Error reading file: ${file.path}');
      }
    }
  }

  try {
    // Save the extracted English strings
    await save('en', allEnglishStrings);
  } catch (e) {
    // Handle errors in saving the strings
    spinner.fail('Error: $e');
    exit(1);
  }
  spinner.success('Extracted ${allEnglishStrings.length} strings!');

  // Iterate over all locale codes and translate the strings
  for (final languageCode in allLocales) {
    if (languageCode == 'en') {
      continue;
    }

    final spinner = CliSpin(
      text: 'Translating to $languageCode...',
      spinner: CliSpinners.line,
    ).start();

    try {
      // Translate and save the strings for the current locale
      await translateNSave(languageCode.toString(), allEnglishStrings);
      spinner.success(
          'Saved $languageCode translations to ${assetFolder.path}/$languageCode.json!');
    } catch (e) {
      // Handle errors in translating the strings
      spinner.fail('Error Translating to $languageCode: $e');
    }
  }

  spinner.success('All translations done!');

  // Run `flutter pub get` to update dependencies
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
      // Handle errors in running `flutter pub get`
      spinner.fail('Error running flutter pub get');
      print(result.stderr);
      exit(1);
    }

    spinner.success('flutter pub get done!');
  } catch (e) {
    // Handle errors in running the process
    spinner.fail('Error running flutter pub get: $e');
    exit(1);
  }
}

// Function to translate strings and save the translations
Future<void> translateNSave(
    String languageCode, Map<String, String?> allEnglishStrings) async {
  final Map<String, String?> trStrings = {};

  final langFile = File('${assetFolder.path}/$languageCode.json');

  // Load existing translations if the file exists
  if (await langFile.exists()) {
    final content = await langFile.readAsString();
    final translations = (json.decode(content) as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as String?));

    trStrings.addAll(translations);
  }

  // Translate each English string
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
      // Use Google Translator API to translate the string
      final translation = await translator.translate(
        englishString,
        from: 'en',
        to: languageCode,
      );

      trStrings[englishString] = translation.text;
      spinner.success(
          'Translated \'$englishString\' to $languageCode: \'${translation.text}\'');
    } catch (e) {
      // Handle errors in translating the string
      spinner.fail('Error translating $englishString to $languageCode: $e');

      trStrings[englishString] = null;
    }
  }

  // Save the translations to a file
  await save(languageCode, trStrings);
}

// Function to extract translation strings from the Dart file content
List<String> extractTrStrings(String content) {
  final regExp = RegExp(r'''["'](.*?)["']\s*\.tr''', multiLine: true);

  final matches = regExp.allMatches(content);
  final trStrings = matches.map((match) => match.group(1)!).toList();

  return trStrings;
}

// Function to save translations to a file
Future<void> save(
    String languageCode, Map<String, String?> translations) async {
  final langFile = File('${assetFolder.path}/$languageCode.json');
  await langFile.writeAsString(json.encode(translations));
}
