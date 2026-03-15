import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:logging/logging.dart';
import '../utils/wizard.dart';

class ScaffoldCommand extends Command {
  final _log = Logger('Scaffold');

  @override
  final name = 'scaffold';
  @override
  final description =
      'Interactive wizard to scaffold Docker files for Laravel.';

  @override
  void run() {
    _log.info('🐋 Welcome to the Laravel Dockerize Scaffolder!');
    _log.info('----------------------------------------------');

    // Check if current directory is a Laravel project
    if (!File('artisan').existsSync() || !Directory('app').existsSync()) {
      _log.severe(
          'Error: This is not a Laravel project. Please run in a Laravel project directory (must contain "artisan" and "app/").');
      exit(1);
    }

    final wizard = ScaffoldWizard();
    final options = wizard.run();

    _log.info('\n✅ Scaffolding project with PHP ${options.phpVersion}...');

    // Further logic for file generation will go here

    _log.fine('Finished wizard process.');
  }
}

enum Database { sqlite, mysql, postgres, mariadb }

enum WebSocketTech { soketi, reverb }

enum BaseImage { debian, alpine }

class ScaffoldOptions {
  final String phpVersion;
  final bool useOctane;
  final bool isFilament;
  final Database database;
  final WebSocketTech webSocket;
  final BaseImage baseImage;

  ScaffoldOptions({
    required this.phpVersion,
    required this.useOctane,
    required this.isFilament,
    required this.database,
    required this.webSocket,
    required this.baseImage,
  });
}

class ScaffoldWizard extends Wizard<ScaffoldOptions> {
  @override
  List<WizardStep> get steps => [
        SelectionStep(
          id: 'php_version',
          label: 'PHP Version',
          question: 'Select PHP Version:',
          options: ['8.1', '8.2', '8.3', '8.4'],
        ),
        ConfirmStep(
          id: 'use_octane',
          label: 'Use Octane',
          question: 'Do you want to use Laravel Octane?',
        ),
        ConfirmStep(
          id: 'is_filament',
          label: 'Filament Project',
          question: 'Is this a Filament project?',
        ),
        EnumSelectionStep<Database>(
          id: 'database',
          label: 'Database',
          question: 'Select Database:',
          options: Database.values,
        ),
        EnumSelectionStep<WebSocketTech>(
          id: 'web_socket',
          label: 'Web Socket Technology',
          question: 'Select WebSocket Technology:',
          options: WebSocketTech.values,
        ),
        EnumSelectionStep<BaseImage>(
          id: 'base_image',
          label: 'Base Image',
          question: 'Which base docker image do you want to use?',
          options: BaseImage.values,
        ),
      ];

  @override
  ScaffoldOptions build(Map<String, dynamic> answers) {
    return ScaffoldOptions(
      phpVersion: answers['php_version'],
      useOctane: answers['use_octane'],
      isFilament: answers['is_filament'],
      database: answers['database'],
      webSocket: answers['web_socket'],
      baseImage: answers['base_image'],
    );
  }
}
