import 'package:cli/models/scaffold_options.dart';
import 'package:cli/services/generator.dart';
import 'package:cli/services/manage_docker_compose.dart';
import 'package:file/memory.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratorService', () {
    late GeneratorService generator;
    late MemoryFileSystem fs;

    setUp(() {
      fs = MemoryFileSystem();
      generator = GeneratorService(fs: fs);
    });

    group('Toolbox Generation', () {
      test(
        'generateToolBox creates "tool" file even if Laravel app directory exists',
        () {
          // Create Laravel-like structure in memory
          fs.directory('app').createSync();
          fs.directory('routes').createSync();
          fs.file('routes/web.php').createSync(recursive: true);

          // This will succeed because it's using the memory file system
          // and 'tool' doesn't exist as a directory there.
          generator.generateToolBox();

          expect(fs.file('tool').existsSync(), isTrue);
          expect(fs.directory('app').existsSync(), isTrue);
        },
      );

      test('generateToolArt creates art tool', () {
        generator.generateToolArt();
        expect(fs.file('art').existsSync(), isTrue);
      });

      test('generateToolCmpsr creates cmpsr tool', () {
        generator.generateToolCmpsr();
        expect(fs.file('cmpsr').existsSync(), isTrue);
      });

      test('generateToolIart creates iart tool', () {
        generator.generateToolIart();
        expect(fs.file('iart').existsSync(), isTrue);
      });

      test('generateToolNd creates nd tool', () {
        generator.generateToolNd();
        expect(fs.file('nd').existsSync(), isTrue);
      });

      test('generateToolPint creates pint tool', () {
        generator.generateToolPint();
        expect(fs.file('pint').existsSync(), isTrue);
      });
    });

    test(
      'generateDockerfile creates a Dockerfile with correct PHP version',
      () {
        final options = ScaffoldOption(
          phpVersion: .v8_3,
          useOctane: false,
          isFilament: false,
          database: Database.mysql,
          webSocket: WebSocketTech.reverb,
          baseImage: BaseImage.debian,
          useVite: true,
          productionReady: false,
        );

        generator.generateDockerfile(options);

        expect(fs.file('Dockerfile').existsSync(), isTrue);
        final content = fs.file('Dockerfile').readAsStringSync();
        expect(
          content,
          contains('FROM ghcr.io/redfieldchristabel/laravel:8.3-fpm'),
        );
      },
    );

    test(
      'generateNginxConf creates directory structure and files when they do not exist',
      () {
        final options = ScaffoldOption(
          phpVersion: .v8_2,
          useOctane: true,
          isFilament: false,
          database: Database.mysql,
          webSocket: WebSocketTech.soketi,
          baseImage: BaseImage.debian,
          useVite: true,
          productionReady: false,
        );

        generator.generateNginxConf(options);

        expect(fs.file('docker/nginx/app.conf').existsSync(), isTrue);
        expect(fs.file('docker/nginx/app_handler.conf').existsSync(), isTrue);
        expect(
          fs.file('docker/nginx/include/web-socket_handler.conf').existsSync(),
          isTrue,
        );
      },
    );

    test('generateDockerCompose handles SQLite removal', () {
      final options = ScaffoldOption(
        phpVersion: .v8_2,
        useOctane: false,
        isFilament: false,
        database: Database.sqlite,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: false,
        productionReady: false,
      );

      generator.generateDockerCompose(options);

      expect(fs.file('docker-compose.yml').existsSync(), isTrue);
      final content = fs.file('docker-compose.yml').readAsStringSync();

      expect(content, isNot(contains('db:')));
      final service = ManageDockerComposeService(content);
      expect(
        service.hasDependency(
          DockerComposeService.app,
          DockerComposeService.db,
        ),
        isFalse,
      );
    });
  });
}
