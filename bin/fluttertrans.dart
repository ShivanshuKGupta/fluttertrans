import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:fluttertrans/extractor.dart';
import 'package:fluttertrans/globals.dart';
import 'package:fluttertrans/save.dart';
import 'package:fluttertrans/translate_save.dart';

/// Main entry point of the script
void main(List<String> arguments) async {
  /// Show help message if --help or -h argument is passed
  if (arguments.firstOrNull == '--help' || arguments.firstOrNull == '-h') {
    print('Usage: fluttertrans [project_dir]');
    exit(0);
  }

  /// Initialize a spinner to indicate progress
  CliSpin spinner = CliSpin(
    text: 'Extracting strings...',
    spinner: CliSpinners.line,
  ).start();

  /// Set the base directory to the provided argument or current directory
  baseDir = arguments.firstOrNull ?? Directory.current.absolute.path;
  dynamic supportedLocales = <String>[];

  try {
    /// Ensure the asset folder exists
    if (!await assetFolder.exists()) {
      await assetFolder.create(recursive: true);
    }

    /// Ensure the locales file exists
    if (!await localesFile.exists()) {
      localesFile.writeAsStringSync(json.encode({
        "supportedLocales": ['en'],
        "fallbackLocale": "en",
      }));
      spinner.success(
          'Created ${localesFile.path} file!\nPlease add some locales to it and then run the `fluttertrans` command again.');
      return;
    }

    /// Read and parse the locales file
    final localesData = json.decode(await localesFile.readAsString());
    supportedLocales = localesData['supportedLocales'];

    /// Validate the locales data
    if (supportedLocales == null || supportedLocales.isEmpty) {
      throw 'Please add some locales to `${localesFile.path}`\nAnd then try again.';
    }

    if (supportedLocales is! List) {
      throw 'Invalid locales file data. Please make sure supportedLocales is a list of strings.';
    }

    if (supportedLocales.length == 1 && supportedLocales[0] == 'en') {
      throw 'Please add some locales other than English to `${localesFile.path}`\nAnd then try again.';
    }
  } catch (e) {
    /// Handle errors in setting up the asset folder and locales file
    spinner.fail('Error: $e');
    exit(1);
  }

  /// Initialize a map to store all English strings
  final Map<String, String?> allEnglishStrings = {};

  /// Iterate over all Dart files in the lib folder
  await for (final file in libFolder.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      spinner.text = 'Extracting strings from ${file.path}...';
      try {
        /// Read the file content
        final content = await file.readAsString();

        /// Extract translation strings from the content
        final trStrings = extractTrStrings(content);

        /// Add the extracted strings to the map
        for (final trString in trStrings) {
          allEnglishStrings[trString] = trString;
        }
      } catch (e) {
        /// Handle errors in reading the file
        spinner.warn('Error reading file: ${file.path}');
        print('Error reading file: ${file.path}');
      }
    }
  }

  try {
    /// Save the extracted English strings
    await save('en', allEnglishStrings);
  } catch (e) {
    /// Handle errors in saving the strings
    spinner.fail('Error: $e');
    exit(1);
  }
  spinner.success('Extracted ${allEnglishStrings.length} strings!');

  /// Iterate over all locale codes and translate the strings
  for (final languageCode in supportedLocales) {
    if (languageCode == 'en') {
      continue;
    }

    final spinner = CliSpin(
      text: 'Translating to $languageCode...',
      spinner: CliSpinners.line,
    ).start();

    try {
      /// Translate and save the strings for the current locale
      await translateNSave(languageCode.toString(), allEnglishStrings);
      spinner.success(
          'Saved $languageCode translations to ${assetFolder.path}/$languageCode.json!');
    } catch (e) {
      /// Handle errors in translating the strings
      spinner.fail('Error Translating to $languageCode: $e');
    }
  }

  spinner.success('All translations done!');

  /// Run `flutter pub get` to update dependencies
  spinner = CliSpin(
    text: 'Running flutter pub get...',
    spinner: CliSpinners.line,
  ).start();

  try {
    final result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: baseDir,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw ('flutter exited with code ${result.exitCode}');
    }

    spinner.success('flutter pub get done!');
  } catch (e) {
    /// Handle errors in running the process
    spinner.fail('Error running flutter pub get: $e');
    exit(1);
  }
}
