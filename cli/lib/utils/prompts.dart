import 'dart:io';

abstract class PromptProvider {
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
  });

  bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
  });
}

class DefaultPromptProvider implements PromptProvider {
  static const String _hideCursor = '\x1b[?25l';
  static const String _showCursor = '\x1b[?25h';
  static const String _cyan = '\x1b[36m';
  static const String _grey = '\x1b[90m';
  static const String _reset = '\x1b[0m';

  String _getDisplayValue<T>(T value) {
    if (value is EnumValue) return value.value;
    if (value is Enum) return value.name;
    return value.toString();
  }

  @override
  T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
  }) {
    var selectedIndex = 0;
    if (initialValue != null) {
      final index = options.indexOf(initialValue);
      if (index != -1) {
        selectedIndex = index;
      }
    }

    final displayOptions = options.map(_getDisplayValue).toList();
    final initialDisplay = initialValue != null
        ? _getDisplayValue(initialValue)
        : null;

    final hint = initialDisplay != null ? ' [$initialDisplay]' : '';
    stdout.write('$_hideCursor\n$question$hint\n');

    int descriptionLines = 0;
    if (description != null) {
      descriptionLines = description.split('\n').length;
      stdout.write('$_grey$description$_reset\n');
    }

    // Initial render
    _renderOptions(displayOptions, selectedIndex);

    // Set terminal to raw mode
    stdin.echoMode = false;
    stdin.lineMode = false;

    try {
      while (true) {
        final key = stdin.readByteSync();

        if (key == 13 || key == 10) {
          // Enter key
          break;
        }

        if (key == 27) {
          // Escape sequence (likely arrow keys)
          final secondByte = stdin.readByteSync();
          if (secondByte == 91) {
            final thirdByte = stdin.readByteSync();
            if (thirdByte == 65) {
              // Up arrow
              selectedIndex =
                  (selectedIndex - 1 + options.length) % options.length;
            } else if (thirdByte == 66) {
              // Down arrow
              selectedIndex = (selectedIndex + 1) % options.length;
            }
          }
        }

        // Redraw options
        stdout.write('\x1b[${options.length}A');
        _renderOptions(displayOptions, selectedIndex);
      }
    } finally {
      // Restore terminal state
      stdin.lineMode = true;
      stdin.echoMode = true;
      stdout.write(_showCursor);
    }

    // Final output: clear selection list and show chosen value
    _clearOptions(options.length + descriptionLines);
    stdout.write(
      '\x1b[2K\r$question $_cyan${displayOptions[selectedIndex]}$_reset\n',
    );

    return options[selectedIndex];
  }

  @override
  bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
  }) {
    final options = ['Yes', 'No'];
    var selectedIndex = defaultValue ? 0 : 1;
    final hint = defaultValue ? '[Y/n]' : '[y/N]';

    stdout.write('$_hideCursor\n$question $hint\n');

    int descriptionLines = 0;
    if (description != null) {
      descriptionLines = description.split('\n').length;
      stdout.write('$_grey$description$_reset\n');
    }

    _renderOptions(options, selectedIndex);

    stdin.echoMode = false;
    stdin.lineMode = false;

    try {
      while (true) {
        final key = stdin.readByteSync();

        if (key == 13 || key == 10) {
          break;
        }

        // Handle 'y' and 'n' keys
        if (key == 121 || key == 89) {
          // y or Y
          selectedIndex = 0;
          break;
        }
        if (key == 110 || key == 78) {
          // n or N
          selectedIndex = 1;
          break;
        }

        if (key == 27) {
          final secondByte = stdin.readByteSync();
          if (secondByte == 91) {
            final thirdByte = stdin.readByteSync();
            if (thirdByte == 65 || thirdByte == 68) {
              // Up or Left
              selectedIndex = 0;
            } else if (thirdByte == 66 || thirdByte == 67) {
              // Down or Right
              selectedIndex = 1;
            }
          }
        }

        stdout.write('\x1b[2A');
        _renderOptions(options, selectedIndex);
      }
    } finally {
      stdin.lineMode = true;
      stdin.echoMode = true;
      stdout.write(_showCursor);
    }

    _clearOptions(2 + descriptionLines);
    stdout.write(
      '\x1b[2K\r$question $_cyan${selectedIndex == 0 ? 'Yes' : 'No'}$_reset\n',
    );

    return selectedIndex == 0;
  }

  void _renderOptions(List<String> options, int selectedIndex) {
    for (var i = 0; i < options.length; i++) {
      stdout.write('\x1b[2K'); // Clear line
      if (i == selectedIndex) {
        stdout.write('$_cyan❯ ${options[i]}$_reset\n');
      } else {
        stdout.write('  ${options[i]}\n');
      }
    }
  }

  void _clearOptions(int count) {
    stdout.write('\x1b[${count}A'); // Move up
    for (var i = 0; i < count; i++) {
      stdout.write('\x1b[2K\n'); // Clear line
    }
    stdout.write('\x1b[${count + 1}A'); // Move back up to question
  }
}

class Prompts {
  static PromptProvider instance = DefaultPromptProvider();

  static T askSelection<T>(
    String question,
    List<T> options, {
    T? initialValue,
    String? description,
  }) => instance.askSelection<T>(
    question,
    options,
    initialValue: initialValue,
    description: description,
  );

  static bool askConfirm(
    String question, {
    bool defaultValue = true,
    String? description,
  }) => instance.askConfirm(
    question,
    defaultValue: defaultValue,
    description: description,
  );
}

mixin EnumValue {
  String get value;
}
