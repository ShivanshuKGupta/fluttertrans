# FlutterTrans CLI

FlutterTrans CLI is a command-line tool designed to facilitate the translation of strings in Flutter applications at compile time. It automates the extraction, translation, and management of localized strings, allowing developers to easily internationalize their Flutter apps. This CLI tool is intended to be used alongside the [trans_flutter package](https://pub.dev/packages/trans_flutter) for seamless integration and dynamic localization.

## Features

- **Automatic Extraction**: Scans your Flutter project for translatable strings. You also have the option to manually mark strings for translation.
- **Translation**: Uses Google Translate to automatically translate strings into multiple languages.
- **Localization Management**: Manages your localization files, ensuring they are up-to-date with the latest translations.
- **Integration**: Seamlessly integrates with your Flutter project.

## Installation

To install the FlutterTrans CLI tool, run the following command to activate the CLI tool:

```sh
dart pub global activate fluttertrans
```

## Usage

To use FlutterTrans CLI, navigate to your Flutter project directory and run the following command:

```sh
fluttertrans
```

### Example

1. Navigate to your Flutter project directory:

    ```sh
    cd /path/to/your/flutter_project
    ```

2. Run the CLI tool:

    ```sh
    fluttertrans
    ```

### Locales File

Ensure you have a `locales` file at `assets/translations/all_locales.json` containing a list of language codes you wish to support. Example:

```json
{
    "supportedLocales": [
        "en",
        "hi",
        "es"
    ],
    "fallbackLocale": "en"
}
```

## How It Works

1. **Extract Strings**: The tool scans your Flutter project for strings marked for translation, strings which end with a `.tr`. However, you can also choose which strings to translate.
2. **Translate Strings**: It uses the Google Translate API to translate these strings into the specified languages.
3. **Save Translations**: Translations are saved in JSON files under `assets/translations/`.
4. **Update Dependencies**: Finally, the tool runs `flutter pub get` to ensure all asset dependencies are up-to-date.

## Integration with trans_flutter

The FlutterTrans CLI tool is designed to work seamlessly with the [trans_flutter package](https://pub.dev/packages/trans_flutter). Make sure to include `trans_flutter` in your `pubspec.yaml` file and configure your app to load the generated translations.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

FlutterTrans CLI is designed to make localization in Flutter projects effortless, ensuring your app is ready for a global audience with minimal effort. Happy coding!
