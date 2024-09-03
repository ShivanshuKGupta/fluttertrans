import 'dart:io';

import 'package:translator/translator.dart';

/// Global variables and constants
late final String baseDir;
final translator = GoogleTranslator();

/// Getter for the lib folder in the project
Directory get libFolder => Directory('$baseDir/lib');

/// Getter for the assets/translations folder
Directory get assetFolder => Directory('$baseDir/assets/translations');

/// Getter for the locales file in the assets/translations folder
File get localesFile => File('${assetFolder.path}/all_locales.json');
