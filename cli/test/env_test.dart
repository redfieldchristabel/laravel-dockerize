import 'dart:io';
import 'package:cli/models/scaffold_options.dart';
import 'package:cli/services/env.dart';
import 'package:test/test.dart';

void main() {
  group('EnvService', () {
    late EnvService service;
    late File envFile;
    late File exampleFile;

    setUp(() {
      service = EnvService();
      envFile = File('.env');
      exampleFile = File('.env.example');

      // Ensure a clean state before each test
      if (envFile.existsSync()) envFile.deleteSync();
      if (exampleFile.existsSync()) exampleFile.deleteSync();
    });

    tearDown(() {
      if (envFile.existsSync()) envFile.deleteSync();
      if (exampleFile.existsSync()) exampleFile.deleteSync();
    });

    test('createFile should copy from .env.example if .env does not exist', () {
      exampleFile.writeAsStringSync('KEY=VALUE');

      service.createFile();

      expect(envFile.existsSync(), isTrue);
      expect(envFile.readAsStringSync(), contains('KEY=VALUE'));
      expect(service.envExist, isTrue);
    });

    test(
      'configureDatabase should update DB_CONNECTION and DB_HOST for MySQL',
      () {
        envFile.writeAsStringSync('DB_CONNECTION=old\nDB_HOST=127.0.0.1');
        service.envExist = true;

        final options = ScaffoldOption(
          phpVersion: '8.2',
          useOctane: false,
          isFilament: false,
          database: Database.mysql,
          webSocket: WebSocketTech.reverb,
          baseImage: BaseImage.debian,
          useVite: true,
          productionReady: false,
        );

        service.configureDatabase(options);

        final content = envFile.readAsStringSync();
        expect(content, contains('DB_CONNECTION=mysql'));
        expect(content, contains('DB_HOST=db'));
      },
    );

    test('configureDatabase should comment out fields for SQLite', () {
      envFile.writeAsStringSync(
        'DB_CONNECTION=mysql\n'
        'DB_DATABASE=laravel\n'
        'DB_USERNAME=root',
      );
      service.envExist = true;

      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: false,
        isFilament: false,
        database: Database.sqlite,
        webSocket: WebSocketTech.reverb,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: false,
      );

      service.configureDatabase(options);

      final content = envFile.readAsStringSync();
      expect(content, contains('DB_CONNECTION=sqlite'));
      expect(content, contains('# DB_DATABASE='));
      expect(content, contains('# DB_USERNAME='));
    });

    test('configurePusher should update values when WebSocket is Soketi', () {
      envFile.writeAsStringSync('PUSHER_APP_ID=\nPUSHER_HOST=');
      service.envExist = true;

      final options = ScaffoldOption(
        phpVersion: '8.2',
        useOctane: false,
        isFilament: false,
        database: Database.mysql,
        webSocket: WebSocketTech.soketi,
        baseImage: BaseImage.debian,
        useVite: true,
        productionReady: false,
      );

      service.configurePusher(options);

      final content = envFile.readAsStringSync();
      expect(content, contains('PUSHER_APP_ID=app-id'));
      expect(content, contains('PUSHER_HOST=soketi'));
      expect(content, contains('VITE_PUSHER_HOST="localhost"'));
    });

    test('configureRedis should set client and host', () {
      envFile.writeAsStringSync('REDIS_CLIENT=predis\nREDIS_HOST=127.0.0.1');
      service.envExist = true;

      service.configureRedis();

      final content = envFile.readAsStringSync();
      expect(content, contains('REDIS_CLIENT=phpredis'));
      expect(content, contains('REDIS_HOST=redis'));
    });
  });
}
