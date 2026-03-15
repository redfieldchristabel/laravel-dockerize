import 'dart:io';
import 'package:cli/models/scaffold_options.dart';
import 'package:cli/services/docker_compose_editor.dart';
import 'package:cli/templates/docker_compose/docker-compose.g.dart';
import 'package:cli/templates/docker_compose/prod.docker-compose.g.dart';
import 'package:cli/templates/dockerfile/cli.g.dart';
import 'package:cli/templates/dockerfile/dockerfile.g.dart';
import 'package:cli/templates/dockerfile/nginx.g.dart';
import 'package:cli/templates/dockerfile/octane.g.dart';
import 'package:cli/templates/dockerfile/vite.g.dart';
import 'package:cli/templates/php_ini.g.dart';
import 'package:logging/logging.dart';

class GeneratorService {
  final _log = Logger('GeneratorService');

  void generateDockerfile(ScaffoldOptions options) {
    final buffer = StringBuffer();

    buffer.write('FROM ghcr.io/redfieldchristabel/laravel:');

    // PHP version
    buffer.write('${options.phpVersion}-');
    _log.finest('PHP version: ${options.phpVersion}');

    // CLI / FPM
    if (options.useOctane) {
      buffer.write('cli');
      _log.finest('Variant: cli (Octane)');
    } else {
      buffer.write('fpm');
      _log.finest('Variant: fpm');
    }

    // Alpine must be right after CLI
    if (options.baseImage == BaseImage.alpine) {
      buffer.write('-alpine');
      _log.finest('Base Image: alpine');
    } else {
      _log.finest('Base Image: debian');
    }

    // Filament comes after alpine (if present)
    if (options.isFilament) {
      buffer.write('-filament');
      _log.finest('Filament: true');
    }

    // Octane-swoole always last
    if (options.useOctane) {
      buffer.write('-octane-swoole');
      _log.finest('Octane swoole: true');
    }

    buffer.writeln(' AS dev\n');

    // Append the Dockerfile template
    buffer.writeln(
      options.useOctane ? dockerfileOctaneTemplate : dockerfileTemplate,
    );

    // Write to Dockerfile
    File('Dockerfile').writeAsStringSync(buffer.toString());
    _log.fine('Dockerfile generated.');
  }

  void generateCliDockerfile(ScaffoldOptions options) {
    if (options.useOctane) {
      _log.fine(
        'Skipping cli.Dockerfile because Octane uses the cli variant by default.',
      );
      return;
    }

    final buffer = StringBuffer();

    buffer.write('FROM ghcr.io/redfieldchristabel/laravel:');

    // PHP version
    buffer.write('${options.phpVersion}-');
    _log.finest('CLI PHP version: ${options.phpVersion}');

    // Always cli
    buffer.write('cli');
    _log.finest('CLI Variant: cli');

    // Alpine must be right after CLI
    if (options.baseImage == BaseImage.alpine) {
      buffer.write('-alpine');
      _log.finest('CLI Base Image: alpine');
    } else {
      _log.finest('CLI Base Image: debian');
    }

    // Filament comes after alpine (if present)
    if (options.isFilament) {
      buffer.write('-filament');
      _log.finest('CLI Filament: true');
    }

    buffer.writeln(' AS dev\n');

    // Append the Dockerfile template (same as main for now)
    buffer.writeln(dockerfileCliTemplate);

    // Write to cli.Dockerfile
    File('cli.Dockerfile').writeAsStringSync(buffer.toString());
    _log.fine('cli.Dockerfile generated.');
  }

  void generateNginxDockerfile(ScaffoldOptions options) {
    File('nginx.Dockerfile').writeAsStringSync(dockerfileNginxTemplate);
    _log.fine('nginx.Dockerfile generated.');
  }

  void generateViteDockerfile(ScaffoldOptions options) {
    File('vite.Dockerfile').writeAsStringSync(dockerfileViteTemplate);
    _log.fine('vite.Dockerfile generated.');
  }

  void generatePhpIni() {
    File('docker/php/file.ini').writeAsStringSync(phpIniTemplate);
    _log.fine('php.ini (file.ini) generated.');
  }

  void generateDockerCompose(ScaffoldOptions options) {
    final service = DockerComposeEditorService(dockerComposeTemplate);

    // 1. Handle Database
    if (options.database == Database.sqlite) {
      _log.finest('Removing mysql and phpmyadmin services for SQLite');
      service.removeService(.mysql);
      service.removeService(.phpmyadmin);

      // Remove mysql from depends_on
      service.removeDependsOn(.app, .mysql);
      service.removeDependsOn(.queue, .mysql);
    }

    // 2. Handle Vite
    if (!options.useVite) {
      _log.finest('Removing vite and node services');
      service.removeService(.vite);
      service.removeService(.node);
    }

    // 3. Handle WebSocket
    if (options.webSocket != WebSocketTech.soketi) {
      _log.finest('Removing soketi service');
      service.removeService(.soketi);
    }

    // Write the modified yaml
    File('docker-compose.yml').writeAsStringSync(service.toString());
    _log.fine('docker-compose.yml generated.');
  }

  void generateProdDockerCompose(ScaffoldOptions options) {
    if (!options.productionReady) {
      _log.finest(
        'Skipping prod.docker-compose.yml because production_ready is false',
      );
      return;
    }
    File(
      'prod.docker-compose.yml',
    ).writeAsStringSync(dockercomposeProdDockerComposeTemplate);

    _log.fine('prod.docker-compose.yml generated.');
  }
}
