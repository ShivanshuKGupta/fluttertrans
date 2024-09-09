import 'dart:convert';
import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:fluttertrans/src/globals.dart';

Future<List<String>> getSupportedLocales() async {
  CliSpin spinner = CliSpin(
    text: 'Getting supported locales...',
    spinner: CliSpinners.line,
  ).start();

  try {
    /// Ensure the asset folder exists
    if (!await assetFolder.exists()) {
      await assetFolder.create(recursive: true);
    }

    /// Ensure the locales file exists
    if (!await localesFile.exists()) {
      localesFile.writeAsStringSync(prettyJson.convert({
        "supportedLocales": ['en'],
        "fallbackLocale": "en",
      }));
      spinner.success(
          'Created ${localesFile.path} file!\nPlease add some locales to it and then run the `fluttertrans` command again.');
      exit(0);
    }

    /// Read and parse the locales file
    final localesData = json.decode(await localesFile.readAsString());
    dynamic supportedLocales = localesData['supportedLocales'];

    /// Validate the locales data
    if (supportedLocales == null || supportedLocales.isEmpty) {
      throw 'Please add some locales to `${localesFile.path}`\nAnd then try again.';
    }

    if (supportedLocales is! List) {
      throw 'Invalid locales file data. Delete `${localesFile.path}` and try again.';
    }

    if (supportedLocales.length == 1 && supportedLocales[0] == 'en') {
      throw 'Please add some locales other than English to `${localesFile.path}`\nAnd then try again.';
    }

    spinner.success('Supported locales: $supportedLocales');
    return supportedLocales.cast<String>();
  } catch (e) {
    /// Handle errors in setting up the asset folder and locales file
    spinner.fail('Error: $e');
    exit(1);
  }
}
