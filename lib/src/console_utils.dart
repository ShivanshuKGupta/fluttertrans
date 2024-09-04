import 'dart:io';

import 'package:dart_console/dart_console.dart';

extension WriteColoured on Console {
  void writeColored(String text, [ConsoleColor? color]) {
    if (color != null) {
      setForegroundColor(color);
    }
    write(text);
    resetColorAttributes();
  }

  void writeColoredLine(String text, [ConsoleColor? color]) {
    writeColored("$text\n", color);
  }
}

/// Prompts the user to choose 1 option out of all [options]
T chooseOne<T>(
  /// The options to choose from.
  final List<T> options, {
  /// A function that returns the text to display for a given option.
  /// If not provided the default is to call `toString` on the option.
  String Function(T option)? getOptionText,

  /// The prompt to display to the user.
  String prompt = "Select an option:",

  /// The hint to display to the user.
  String hint = "(Move up and down to select. Press Enter to confirm.)",

  /// The initial selection index.
  final int initialSelection = 0,
}) {
  /// Constants
  const starEmoji = '✨';
  const selectedColor = ConsoleColor.brightYellow;

  /// Assertions
  assert(options.isNotEmpty, 'Options must not be empty.');

  final console = Console();
  // final starEmoji = console.supportsEmoji ? '✨' : '*';
  final startLine = console.cursorPosition!.row;
  int currentSelection = initialSelection % options.length;

  getOptionText ??= (option) => option.toString();
  prompt = '$starEmoji $prompt';
  console.hideCursor();

  /// Prints the menu
  void printMenu() {
    console.cursorPosition = Coordinate(startLine, 0);

    /// Prompt
    console.writeLine(prompt);

    /// All Options
    for (int i = 0; i < options.length; i++) {
      final selected = i == currentSelection;
      final prefix = selected ? '>' : ' ';
      console.writeColoredLine(
        '   $prefix ${getOptionText!(options[i])}',
        selected ? selectedColor : null,
      );
    }

    /// Hint
    console.writeLine("   $hint");
  }

  /// Resets the terminal and prints the chosen option
  void resetTerminal([T? chosenOption]) {
    /// Terminal properties
    console.resetColorAttributes();
    console.showCursor();

    /// Removing everything below startLine
    for (var i = 0; i < options.length + 2; i++) {
      console.cursorPosition = Coordinate(startLine + i, 0);
      console.eraseLine();
    }

    /// Printing the chosen option
    console.cursorPosition = Coordinate(startLine, 0);
    if (chosenOption != null) {
      console.write(prompt);
      console.writeColoredLine(
          ' ${getOptionText!(chosenOption)}', selectedColor);
    }
  }

  while (true) {
    printMenu();
    final key = console.readKey();

    switch (key.controlChar) {
      case ControlCharacter.arrowUp:
      case ControlCharacter.arrowLeft:
        currentSelection =
            (currentSelection - 1 + options.length) % options.length;
        break;

      case ControlCharacter.arrowDown:
      case ControlCharacter.arrowRight:
      case ControlCharacter.tab:
        currentSelection = (currentSelection + 1) % options.length;
        break;

      case ControlCharacter.enter:
        resetTerminal(options[currentSelection]);
        return options[currentSelection];

      case ControlCharacter.home:
        currentSelection = 0;
        break;

      case ControlCharacter.end:
        currentSelection = options.length - 1;
        break;

      case ControlCharacter.ctrlC:
        resetTerminal();
        console.writeErrorLine('Keyboard Interrupt. Exiting...');
        exit(1);

      default:
        break;
    }
  }
}

Set<T> chooseMany<T>(
  List<T> options, {
  String Function(T option)? getOptionText,
  String prompt = "Select options:",
  String hint =
      "(Move up and down to select. Press right arrow or space to select. Press Enter to confirm.)",
  Set<T>? initialSelections,
}) {
  final console = Console();
  final startLine = console.cursorPosition!.row;
  final selectedColor = ConsoleColor.brightYellow;
  final chosenColor = ConsoleColor.brightGreen;

  getOptionText ??= (option) => option.toString();
  prompt = '✨ $prompt';
  console.hideCursor();

  final Set<T> selectedOptions = {...?initialSelections};
  var currentSelection = 0;

  void printMenu() {
    console.cursorPosition = Coordinate(startLine, 0);
    console.writeLine(prompt);

    for (var i = 0; i < options.length; i++) {
      final chosen = selectedOptions.contains(options[i]);
      final selected = i == currentSelection;
      final prefix = chosen ? '[✔]' : '[ ]';
      final color = selected ? selectedColor : (chosen ? chosenColor : null);
      console.writeColoredLine(
        '   $prefix ${getOptionText!(options[i])}',
        color,
      );
    }

    console.writeLine("   $hint");
  }

  void resetTerminal([List<T>? chosenOptions]) {
    console.resetColorAttributes();
    console.showCursor();

    /// Removing everything below startLine
    for (var i = 0; i < options.length + 2; i++) {
      console.cursorPosition = Coordinate(startLine + i, 0);
      console.eraseLine();
    }

    /// Printing the chosen option
    console.cursorPosition = Coordinate(startLine, 0);
    if (chosenOptions != null) {
      console.write(prompt);
      console.writeColoredLine(
          ' ${chosenOptions.map(getOptionText!).join(', ')}', selectedColor);
    }
  }

  while (true) {
    printMenu();
    final key = console.readKey();

    switch (key.controlChar) {
      case ControlCharacter.arrowUp:
        currentSelection =
            (currentSelection - 1 + options.length) % options.length;
        break;

      case ControlCharacter.arrowDown:
      case ControlCharacter.tab:
        currentSelection = (currentSelection + 1) % options.length;
        break;

      case ControlCharacter.enter:
        resetTerminal(selectedOptions.toList());
        return selectedOptions;

      case ControlCharacter.arrowLeft:
        selectedOptions.remove(options[currentSelection]);
        break;

      case ControlCharacter.arrowRight: // case ControlCharacter.space:
        if (selectedOptions.contains(options[currentSelection])) {
          selectedOptions.remove(options[currentSelection]);
        } else {
          selectedOptions.add(options[currentSelection]);
        }
        break;

      case ControlCharacter.home:
        currentSelection = 0;
        break;

      case ControlCharacter.end:
        currentSelection = options.length - 1;
        break;

      case ControlCharacter.ctrlC:
        resetTerminal();
        console.writeErrorLine('Keyboard Interrupt. Exiting...');
        exit(1);

      case ControlCharacter.escape:
        selectedOptions.clear();
        break;

      case ControlCharacter.ctrlA:
        selectedOptions.clear();
        selectedOptions.addAll(options);
        break;

      default:
        print(
            'key.controlChar: ${key.controlChar} & key.char: \'${key.char}\'');
        break;
    }
  }
}
