import 'package:args/command_runner.dart';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:cli/commands/scaffold.dart';

void main(List<String> arguments) async {
  // Setup Logging
  Logger.root.onRecord.listen((record) {
    if (record.level >= Level.SEVERE) {
      stderr.writeln('\x1b[31m${record.message}\x1b[0m');
    } else {
      stdout.writeln(record.message);
    }
  });

  final runner = CommandRunner(
    'laravel-dockerize',
    'CLI for redfieldchristabel/laravel-dockerize',
  )
    ..argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Enable verbose logging.',
    )
    ..addCommand(ScaffoldCommand());

  try {
    final argResults = runner.argParser.parse(arguments);

    // Set log level based on verbose flag
    if (argResults['verbose'] == true) {
      Logger.root.level = Level.ALL;
    } else {
      Logger.root.level = Level.INFO;
    }

    await runner.run(arguments);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln();
    stderr.writeln(e.usage);
    exit(64);
  } catch (e) {
    stderr.writeln('An unexpected error occurred: $e');
    exit(1);
  }
}
