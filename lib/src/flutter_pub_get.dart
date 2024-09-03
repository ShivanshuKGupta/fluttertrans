import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:fluttertrans/src/globals.dart';

Future<void> flutterPubGet() async {
  final spinner = CliSpin(
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
