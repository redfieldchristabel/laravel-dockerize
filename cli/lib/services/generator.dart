import 'package:cli/models/scaffold_options.dart';
import 'package:cli/services/manage_docker_compose.dart';
import 'package:cli/templates/docker_compose/db.docker-compose.g.dart';
import 'package:cli/templates/docker_compose/docker-compose.g.dart';
import 'package:cli/templates/docker_compose/prod.docker-compose.g.dart';
import 'package:cli/templates/dockerfile/cli.g.dart';
import 'package:cli/templates/dockerfile/dockerfile.g.dart';
import 'package:cli/templates/dockerfile/nginx.g.dart';
import 'package:cli/templates/dockerfile/octane.g.dart';
import 'package:cli/templates/dockerfile/vite.g.dart';
import 'package:cli/templates/nginx_config/app.g.dart';
import 'package:cli/templates/nginx_config/fpm_handler.g.dart';
import 'package:cli/templates/nginx_config/octane_handler.g.dart';
import 'package:cli/templates/nginx_config/reverb_handler.g.dart';
import 'package:cli/templates/nginx_config/soketi_handler.g.dart';
import 'package:cli/templates/php_ini.g.dart';
import 'package:cli/templates/tool/art.g.dart';
import 'package:cli/templates/tool/cmpsr.g.dart';
import 'package:cli/templates/tool/iart.g.dart';
import 'package:cli/templates/tool/nd.g.dart';
import 'package:cli/templates/tool/pint.g.dart';
import 'package:cli/templates/tool/tool.g.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';

class GeneratorService {
  final _log = Logger('GeneratorService');
  final FileSystem fs;

  GeneratorService({FileSystem? fs}) : fs = fs ?? const LocalFileSystem();

  void generateDockerfile(ScaffoldOption options) {
    final buffer = StringBuffer();

    buffer.write('FROM ghcr.io/redfieldchristabel/laravel:');

    // PHP version
    buffer.write('${options.phpVersion.value}-');
    _log.finest('PHP version: ${options.phpVersion.value}');

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

    buffer.write(' AS ');

    buffer.writeln('${options.useOctane ? 'base' : 'dev'}\n');

    // Append the Dockerfile template
    buffer.writeln(
      options.useOctane ? dockerfileOctaneTemplate : dockerfileTemplate,
    );

    // Write to Dockerfile
    fs.file('Dockerfile').writeAsStringSync(buffer.toString());
    _log.fine('Dockerfile generated.');
  }

  void generateCliDockerfile(ScaffoldOption options) {
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
    fs.file('cli.Dockerfile').writeAsStringSync(buffer.toString());
    _log.fine('cli.Dockerfile generated.');
  }

  void generateNginxDockerfile(ScaffoldOption options) {
    fs.file('nginx.Dockerfile').writeAsStringSync(dockerfileNginxTemplate);
    _log.fine('nginx.Dockerfile generated.');
  }

  void generateViteDockerfile(ScaffoldOption options) {
    fs.file('vite.Dockerfile').writeAsStringSync(dockerfileViteTemplate);
    _log.fine('vite.Dockerfile generated.');
  }

  void generatePhpIni() {
    fs.directory('docker/php').createSync(recursive: true);
    fs.file('docker/php/file.ini').writeAsStringSync(phpIniTemplate);
    _log.fine('php.ini (file.ini) generated.');
  }

  void generateNginxConf(ScaffoldOption options) {
    fs.directory('docker/nginx/include').createSync(recursive: true);

    fs.file('docker/nginx/app.conf').writeAsStringSync(nginxconfigAppTemplate);
    _log.fine('NGINX app.conf generated.');

    final content = options.useOctane
        ? nginxconfigOctaneHandlerTemplate
        : nginxconfigFpmHandlerTemplate;
    _log.finest('Use ${options.useOctane ? 'octane' : 'fpm'} handler');

    fs.file('docker/nginx/app_handler.conf').writeAsStringSync(content);

    // generate web-soket handler
    final wsContent = options.webSocket == WebSocketTech.soketi
        ? nginxconfigSoketiHandlerTemplate
        : nginxconfigReverbHandlerTemplate;
    _log.finest(
      'Use ${options.webSocket == WebSocketTech.soketi ? 'soketi' : 'reverb'} '
      'handler',
    );

    fs
        .file('docker/nginx/include/web-socket_handler.conf')
        .writeAsStringSync(wsContent);

    _log.fine('NGINX app_handler.conf generated.');
  }

  void generateDockerCompose(ScaffoldOption options) {
    final service = ManageDockerComposeService(dockerComposeTemplate);
    final dbService = ManageDockerComposeService(
      dockercomposeDbDockerComposeTemplate,
    );

    // Handle Database
    switch (options.database) {
      case Database.sqlite:
        _log.finest('Removing mysql and phpmyadmin services for SQLite');
        service.removeService(.phpmyadmin);

        // Remove db from depends_on
        service.removeDependsOn(.app, .db);
        service.removeDependsOn(.queue, .db);
        break;
      case Database.mysql:
        _log.finest('copy mysql from the template');
        final mysqlNode = dbService.getService(.mysql)!;
        _log.finest('inject mysql service to docker compose');
        service.setService(.db, mysqlNode);
        break;
      case Database.postgres:
        _log.finest('copy postgres from the template');
        final pgNode = dbService.getService(.postgres)!;
        _log.finest('inject postgres service to docker compose');
        service.setService(.db, pgNode);
        service.removeService(.phpmyadmin);
        break;
      case Database.mariadb:
        _log.finest('copy mariadb from the template');
        final mariaNode = dbService.getService(.mariadb)!;
        _log.finest('inject mariadb service to docker compose');
        service.setService(.db, mariaNode);
        break;
    }

    // Handle Vite
    if (!options.useVite) {
      _log.finest('Removing vite and node services');
      service.removeService(.vite);
      service.removeService(.node);
    }

    // Handle WebSocket
    if (options.webSocket != WebSocketTech.soketi) {
      _log.finest('Removing soketi service');
      service.removeService(.soketi);
    } else {
      _log.finest('Removing reverb service');
      service.removeService(.reverb);
    }

    // Handle octane image
    if (options.useOctane) {
      final appImage = r'${APP_NAME}/app:dev';

      //   Octane can utilize same image as app for cli
      service.setImage(.queue, appImage);
      service.setImage(.scheduler, appImage);

      if (options.webSocket == .reverb) {
        service.setImage(.reverb, appImage);
      }
    }

    // Write the modified yaml
    fs.file('docker-compose.yml').writeAsStringSync(service.toString());
    _log.fine('docker-compose.yml generated.');
  }

  void generateProdDockerCompose(ScaffoldOption options) {
    if (!options.productionReady) {
      _log.finest(
        'Skipping prod.docker-compose.yml because production_ready is false',
      );
      return;
    }

    final service = ManageDockerComposeService(
      dockercomposeProdDockerComposeTemplate,
    );

    final dbService = ManageDockerComposeService(
      dockercomposeDbDockerComposeTemplate,
    );

    // 1. Handle Database
    switch (options.database) {
      case Database.sqlite:
        _log.finest('Removing mysql and phpmyadmin services for SQLite');

        // Remove db from depends_on
        service.removeDependsOn(.app, .db);
        service.removeDependsOn(.queue, .db);
        service.removeDependsOn(.scheduler, .db);
        break;
      case Database.mysql:
        _log.finest('copy mysql from the template');
        final mysqlNode = dbService.getService(.mysql)!;
        _log.finest('inject mysql service to docker compose');
        service.setService(.db, mysqlNode);
        break;
      case Database.postgres:
        _log.finest('copy postgres from the template');
        final pgNode = dbService.getService(.postgres)!;
        _log.finest('inject postgres service to docker compose');
        service.setService(.db, pgNode);
        break;
      case Database.mariadb:
        _log.finest('copy mariadb from the template');
        final mariaNode = dbService.getService(.mariadb)!;
        _log.finest('inject mariadb service to docker compose');
        service.setService(.db, mariaNode);
        break;
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
    } else {
      _log.finest('Removing reverb service');
      service.removeService(.reverb);
    }

    // Handle use octane
    if (options.useOctane) {
      final appImage = r'<registry-url>/cli:\${APP_VERSION:-latest}';
      //   Octane can utilize same image as app for cli
      service.setImage(.queue, appImage);
      service.setImage(.scheduler, appImage);

      if (options.webSocket == .reverb) {
        service.setImage(.reverb, appImage);
      }
    }

    // Write the modified yaml
    fs.file('prod.docker-compose.yml').writeAsStringSync(service.toString());
    _log.fine('prod.docker-compose.yml generated.');
  }

  void generateToolArt() {
    fs.file('art').writeAsStringSync(toolArtTemplate);
    _log.fine('art generated.');
  }

  void generateToolBox() {
    fs.file('tool').writeAsStringSync(toolTemplate);
    _log.fine('tool generated.');
  }

  void generateToolCmpsr() {
    fs.file('cmpsr').writeAsStringSync(toolCmpsrTemplate);
    _log.fine('cmpsr generated.');
  }

  void generateToolIart() {
    fs.file('iart').writeAsStringSync(toolIartTemplate);
    _log.fine('iart generated.');
  }

  void generateToolNd() {
    fs.file('nd').writeAsStringSync(toolNdTemplate);
    _log.fine('nd generated.');
  }

  void generateToolPint() {
    fs.file('pint').writeAsStringSync(toolPintTemplate);
    _log.fine('pint generated.');
  }
}
