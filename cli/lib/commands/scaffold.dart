import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:cli/services/generator.dart';
import 'package:cli/services/env.dart';
import 'package:logging/logging.dart';
import '../utils/wizard.dart';
import '../models/scaffold_options.dart';

class ScaffoldCommand extends Command {
  final _log = Logger('Scaffold');
  final _generatorService = GeneratorService();
  final _envService = EnvService();

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
    final option = wizard.run();

    _log.info('\n✅ Scaffolding project with PHP ${option.phpVersion}...');

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
    _generatorService.generateDockerfile(option);
    _generatorService.generateCliDockerfile(option);
    _generatorService.generateNginxDockerfile(option);
    _generatorService.generateViteDockerfile(option);
    _log.info('🚀 Dockerfiles generated successfully!');

    _log.info('Generating Docker Compose files...');
    _generatorService.generateDockerCompose(option);
    _generatorService.generateProdDockerCompose(option);
    _log.info('🚀 Docker Compose files generated successfully!');

    _log.info('📄 Generating config files...');
    _generatorService.generatePhpIni();
    _generatorService.generateNginxConf(option);
    _log.info('🚀 Config files generated successfully!');

    _log.info('Generating tools...');
    _generatorService.generateToolArt();
    _generatorService.generateToolBox();
    _generatorService.generateToolCmpsr();
    _generatorService.generateToolIart();
    _generatorService.generateToolNd();
    _generatorService.generateToolPint();
    _log.info('🚀 Tools generated successfully!');

    _envService.configure(option);

    _log.fine('Finished wizard process.');

    //   TODO: check for pint and remove it from laravel composer with fun message
  }
}

class ScaffoldWizard extends Wizard<ScaffoldOption> {
  @override
  List<WizardStep> get steps => [
    EnumSelectionStep<PhpVersion>(
      id: 'php_version',
      label: 'PHP Version',
      question: 'Select PHP Version:',
      options: PhpVersion.values,
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
  ScaffoldOption build(Map<String, dynamic> answers) {
    return ScaffoldOption(
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
