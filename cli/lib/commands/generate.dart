import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';

class GenerateCommand extends Command {
  final _log = Logger('Generate');

  @override
  String get description => 'Generate files for Laravel Dockerize';

  @override
  String get name => 'generate';

  @override
  List<String> get aliases => ['g', 'gen'];

  @override
  void run() {
    _log.shout(
      'Coming soon!!!\n\n\n'
      'This can help you generate part of the '
      'files for Laravel Dockerize.',
    );
  }
}
