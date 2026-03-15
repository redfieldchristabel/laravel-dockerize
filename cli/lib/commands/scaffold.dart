import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli/services/generator.dart';
import 'package:logging/logging.dart';
import '../utils/wizard.dart';
import '../models/scaffold_options.dart';

class ScaffoldCommand extends Command {
  final _log = Logger('Scaffold');
  final _generatorService = GeneratorService();

  @override
  final name = 'scaffold';
  @override
  final description =
      'Interactive wizard to scaffold Docker files for Laravel.';

  @override
  void run() {
    // Check if current directory is a Laravel project
    // if (!File('artisan').existsSync() || !Directory('app').existsSync()) {
    //   _log.severe(
    //     'Error: This is not a Laravel project. Please run in a Laravel project directory (must contain "artisan" and "app/").',
    //   );
    //   exit(1);
    // }

    _log.info('🐋 Welcome to the Laravel Dockerize Scaffolder!');
    _log.info('----------------------------------------------');

    final wizard = ScaffoldWizard();
    final options = wizard.run();

    _log.info('\n✅ Scaffolding project with PHP ${options.phpVersion}...');

    // 1. Directory Preparation
    _log.info('📁 Creating docker directories...');
    try {
      Directory('docker/nginx').createSync(recursive: true);
      _log.finest('"docker/nginx" folder created');
      Directory('docker/php').createSync(recursive: true);
      _log.finest('"docker/php" folder created');
    } catch (e) {
      _log.severe('Failed to create directories: $e');
      exit(1);
    }

    // 2. File Generation
    _log.info('📄 Generating Dockerfiles...');
    _generatorService.generateDockerfile(options);
    _generatorService.generateCliDockerfile(options);
    _generatorService.generateNginxDockerfile(options);
    _generatorService.generateViteDockerfile(options);
    _log.info('🚀 Dockerfiles generated successfully!');

    _log.info('Generating Docker Compose files...');
    _generatorService.generateDockerCompose(options);
    _generatorService.generateProdDockerCompose(options);
    _log.info('🚀 Docker Compose files generated successfully!');

    _log.info('📄 Generating PHP.ini...');
    _generatorService.generatePhpIni();
    _log.info('🚀 PHP.ini generated successfully!');

    _log.fine('Finished wizard process.');
  }
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
    ConfirmStep(
      id: 'use_vite',
      label: 'Vite',
      question: 'Do you want to use Vite?',
    ),
    ConfirmStep(
      id: 'production_ready',
      label: 'Production Ready',
      question: 'Generate a compose file for production environment also?',
      description:
          'This can be useful for deploying to production.\n'
          'You can enable this later',
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
      useVite: answers['use_vite'],
      productionReady: answers['production_ready'],
    );
  }
}
