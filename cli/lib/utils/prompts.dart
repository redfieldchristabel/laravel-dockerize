import 'dart:io';

class Prompts {
  static const String _hideCursor = '\x1b[?25l';
  static const String _showCursor = '\x1b[?25h';
  static const String _cyan = '\x1b[36m';
  static const String _reset = '\x1b[0m';

  static String askSelection(String question, List<String> options, {String? initialValue}) {
    var selectedIndex = 0;
    if (initialValue != null) {
      final index = options.indexOf(initialValue);
      if (index != -1) {
        selectedIndex = index;
      }
    }

    final hint = initialValue != null ? ' [$initialValue]' : '';
    stdout.write('$_hideCursor\n$question$hint\n');

    // Initial render
    _renderOptions(options, selectedIndex);

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
              selectedIndex = (selectedIndex - 1 + options.length) % options.length;
            } else if (thirdByte == 66) {
              // Down arrow
              selectedIndex = (selectedIndex + 1) % options.length;
            }
          }
        }

        // Move cursor back up to redraw
        stdout.write('\x1b[${options.length}A');
        _renderOptions(options, selectedIndex);
      }
    } finally {
      // Restore terminal state
      stdin.lineMode = true;
      stdin.echoMode = true;
      stdout.write(_showCursor);
    }

    // Final output: clear the selection list and show chosen value
    _clearOptions(options.length);
    // Use \x1b[2K to clear the question line before writing the answer
    stdout.write('\x1b[2K\r$question $_cyan${options[selectedIndex]}$_reset\n');
    
    return options[selectedIndex];
  }

  static bool askConfirm(String question, {bool defaultValue = true}) {
    final options = ['Yes', 'No'];
    var selectedIndex = defaultValue ? 0 : 1;
    final hint = defaultValue ? '[Y/n]' : '[y/N]';

    stdout.write('$_hideCursor\n$question $hint\n');
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
        if (key == 121 || key == 89) { // y or Y
          selectedIndex = 0;
          break;
        }
        if (key == 110 || key == 78) { // n or N
          selectedIndex = 1;
          break;
        }

        if (key == 27) {
          final secondByte = stdin.readByteSync();
          if (secondByte == 91) {
            final thirdByte = stdin.readByteSync();
            if (thirdByte == 65 || thirdByte == 68) { // Up or Left
              selectedIndex = 0;
            } else if (thirdByte == 66 || thirdByte == 67) { // Down or Right
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

    _clearOptions(2);
    // Use \x1b[2K to clear the question line before writing the answer
    stdout.write('\x1b[2K\r$question $_cyan${selectedIndex == 0 ? 'Yes' : 'No'}$_reset\n');

    return selectedIndex == 0;
  }

  static void _renderOptions(List<String> options, int selectedIndex) {
    for (var i = 0; i < options.length; i++) {
      stdout.write('\x1b[2K'); // Clear line
      if (i == selectedIndex) {
        stdout.write('$_cyan❯ ${options[i]}$_reset\n');
      } else {
        stdout.write('  ${options[i]}\n');
      }
    }
  }

  static void _clearOptions(int count) {
    stdout.write('\x1b[${count}A'); // Move to start of list
    for (var i = 0; i < count; i++) {
      stdout.write('\x1b[2K\n'); // Clear line and move down
    }
    stdout.write('\x1b[${count + 1}A'); // Move back up to question line
  }
}
