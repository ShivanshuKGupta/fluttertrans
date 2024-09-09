import 'dart:io';

import 'package:translator/translator.dart';

/// Global variables and constants
late final String baseDir;
final translator = GoogleTranslator();

/// Getter for the lib folder in the project
final Directory libFolder = Directory('$baseDir/lib');

/// Getter for the assets/translations folder
late final Directory assetFolder;

/// Getter for the locales file in the assets/translations folder
late final File localesFile;
