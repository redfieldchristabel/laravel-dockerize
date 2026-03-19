import 'dart:io';
import 'package:cli/models/scaffold_options.dart';
import 'package:cli/services/generator.dart';
import 'package:cli/services/manage_docker_compose.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratorService', () {
    late GeneratorService generator;

    setUp(() {
      generator = GeneratorService();
    });

    tearDown(() {
      // Clean up generated files
      final files = [
        'Dockerfile',
        'cli.Dockerfile',
        'nginx.Dockerfile',
        'vite.Dockerfile',
        'docker-compose.yml',
        'prod.docker-compose.yml',
        'art',
        'app',
        'cmpsr',
        'iart',
        'nd',
        'pint',
        'docker/php/file.ini',
        'docker/nginx/app.conf',
        'docker/nginx/app_handler.conf',
        'docker/nginx/include/web-socket_handler.conf',
      ];
      for (final path in files) {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      
      // Clean up directories if empty
      final dirs = ['docker/php', 'docker/nginx/include', 'docker/nginx', 'docker'];
      for (final path in dirs) {
        final dir = Directory(path);
        if (dir.existsSync()) {
          try {
             dir.deleteSync(recursive: true);
          } catch (e) {
            // Might not be empty or already deleted
          }
        }
      }
    });

    test('generateDockerfile creates a Dockerfile with correct PHP version', () {
      final options = ScaffoldOption(
        phpVersion: '8.3',
        useOctane: false,
        isFilament: false,
        database: Database.mysql,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: false,
      );

      generator.generateDockerfile(options);

      final file = File('Dockerfile');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('FROM ghcr.io/redfieldchristabel/laravel:8.3-fpm'));
    });

    test('generateDockerfile handles Octane and Alpine', () {
      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: true,
        isFilament: true,
        database: Database.mysql,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.alpine,
        useVite: true,
        productionReady: false,
      );

      generator.generateDockerfile(options);

      final file = File('Dockerfile');
      final content = file.readAsStringSync();
      expect(content, contains('8.2-cli-alpine-filament-octane-swoole'));
    });

    test('generateNginxConf creates directory structure and files when they do not exist', () {
      // Ensure the 'docker' directory and its subdirectories do NOT exist
      final dockerDir = Directory('docker');
      if (dockerDir.existsSync()) {
        dockerDir.deleteSync(recursive: true);
      }
      
      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: true,
        isFilament: false,
        database: Database.mysql,
        webSocket: WebSocketTech.soketi,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: false,
      );

      generator.generateNginxConf(options);

      expect(File('docker/nginx/app.conf').existsSync(), isTrue);
      expect(File('docker/nginx/app_handler.conf').existsSync(), isTrue);
      expect(File('docker/nginx/include/web-socket_handler.conf').existsSync(), isTrue);
    });

    test('generateDockerCompose handles SQLite removal', () {
      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: false,
        isFilament: false,
        database: Database.sqlite,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: false,
        productionReady: false,
      );

      generator.generateDockerCompose(options);

      final file = File('docker-compose.yml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      
      // Verify db service key is removed
      expect(content, isNot(contains('db:')));
      
      // Verify phpmyadmin and vite are removed
      expect(content, isNot(contains('phpmyadmin:')));
      expect(content, isNot(contains('vite:')));
      
      // Verify depends_on references are removed using service check
      final service = ManageDockerComposeService(content);
      expect(service.hasDependency(DockerComposeService.app, DockerComposeService.db), isFalse);
      expect(service.hasDependency(DockerComposeService.queue, DockerComposeService.db), isFalse);
    });

    test('generateProdDockerCompose injects DB template', () {
      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: false,
        isFilament: false,
        database: Database.postgres,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: true,
      );

      generator.generateProdDockerCompose(options);

      final file = File('prod.docker-compose.yml');
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      
      // Verify postgres is injected
      expect(content, contains('db:'));
      expect(content, contains('image: postgres:15'));
      
      // Verify mysql-specific remnants are gone (from injection)
      expect(content, isNot(contains('mysql/mysql-server:8.0')));
      expect(content, isNot(contains('phpmyadmin:')));
    });

    test('generateProdDockerCompose handles SQLite removal with db dependency', () {
      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: false,
        isFilament: false,
        database: Database.sqlite,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: true,
      );

      generator.generateProdDockerCompose(options);

      final file = File('prod.docker-compose.yml');
      final content = file.readAsStringSync();
      
      // Verify db dependency is removed using service check
      final service = ManageDockerComposeService(content);
      expect(service.hasDependency(DockerComposeService.app, DockerComposeService.db), isFalse);
      expect(service.hasDependency(DockerComposeService.queue, DockerComposeService.db), isFalse);
      expect(service.hasDependency(DockerComposeService.scheduler, DockerComposeService.db), isFalse);
    });
  });
}
