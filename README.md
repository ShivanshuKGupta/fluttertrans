# FlutterTrans CLI

FlutterTrans CLI is a command-line tool designed to facilitate the translation of strings in Flutter applications at compile time. It automates the extraction, translation, and management of localized strings, allowing developers to easily internationalize their Flutter apps.

## Features

- **Automatic Extraction**: Scans your Flutter project for translatable strings.
- **Translation**: Uses Google Translate to automatically translate strings into multiple languages.
- **Localization Management**: Manages your localization files, ensuring they are up-to-date with the latest translations.
- **Integration**: Seamlessly integrates with your Flutter project and supports running `flutter pub get` after translation.

## Installation

To install the FlutterTrans CLI tool, run the following command to activate the CLI tool:

```sh
dart pub global activate fluttertrans
```

## Usage

To use FlutterTrans CLI, navigate to your Flutter project directory and run the following command:

```sh
fluttertrans [project_dir]
```

### Options

- `--help`, `-h`: Display usage information.

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
[
  "en",
  "es",
  "fr",
  "de"
]
```

## How It Works

1. **Extract Strings**: The tool scans your Flutter project for strings marked for translation (e.g., `tr` function).
2. **Translate Strings**: It uses the Google Translate API to translate these strings into the specified languages.
3. **Save Translations**: Translations are saved in JSON files under `assets/translations/`.
4. **Update Dependencies**: Finally, the tool runs `flutter pub get` to ensure all asset dependencies are up-to-date.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

FlutterTrans CLI is designed to make localization in Flutter projects effortless, ensuring your app is ready for a global audience with minimal effort. Happy coding!
