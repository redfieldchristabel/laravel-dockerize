import 'package:cli/services/manage_docker_compose.dart';
import 'package:cli/templates/docker_compose/db.docker-compose.g.dart';
import 'package:cli/templates/docker_compose/docker-compose.g.dart';
import 'package:test/test.dart';

void main() {
  group('DockerComposeEditorService - DB Template', () {
    late ManageDockerComposeService service;

    setUp(() {
      service = ManageDockerComposeService(
        dockercomposeDbDockerComposeTemplate,
      );
    });

    test('getService returns YamlNode for existing services', () {
      final postgres = service.getService(.postgres);
      final mariadb = service.getService(.mariadb);
      final mysql = service.getService(.mysql);

      expect(postgres, isNotNull);
      expect(mariadb, isNotNull);
      expect(mysql, isNotNull);
      expect(postgres!.value['image'], contains('postgres'));
    });

    test('getService returns null for non-existent services', () {
      // 'app' is not in the db template
      final app = service.getService(.app);
      expect(app, isNull);
    });
  });

  group('DockerComposeEditorService - Main Template Operations', () {
    late ManageDockerComposeService service;

    setUp(() {
      service = ManageDockerComposeService(dockerComposeTemplate);
    });

    test('hasDependency should return true if dependency exists', () {
      expect(service.hasDependency(.app, .db), isTrue);
      expect(service.hasDependency(.queue, .app), isTrue);
      expect(service.hasDependency(.nginx, .app), isTrue);
    });

    test('hasDependency should return false if dependency does not exist', () {
      expect(service.hasDependency(.app, .redis), isFalse);
      expect(service.hasDependency(.nginx, .db), isFalse);
    });

    test(
      'removeService should remove the service from yaml and internal state',
      () {
        expect(service.getService(.phpmyadmin), isNotNull);
        expect(service.toString(), contains('phpmyadmin:'));

        service.removeService(.phpmyadmin);

        expect(service.getService(.phpmyadmin), isNull);
        expect(service.toString(), isNot(contains('phpmyadmin:')));
      },
    );

    test(
      'tryRemoveService should return true if service exists and is removed',
      () {
        expect(service.getService(.mailpit), isNotNull);

        final result = service.tryRemoveService(.mailpit);

        expect(result, isTrue);
        expect(service.getService(.mailpit), isNull);
      },
    );

    test('tryRemoveService should return false if service does not exist', () {
      // .postgres is not in the main template
      final result = service.tryRemoveService(.postgres);

      expect(result, isFalse);
    });

    test('setService should add or update a service', () {
      final dbTemplateService = ManageDockerComposeService(
        dockercomposeDbDockerComposeTemplate,
      );
      final postgresNode = dbTemplateService.getService(.postgres)!;

      service.setService(.db, postgresNode);

      final updatedDb = service.getService(.db);
      expect(updatedDb!.value['image'], contains('postgres'));
    });

    test('setImage should update the image property', () {
      const newImage = 'mysql:8.0';
      service.setImage(DockerComposeService.app, newImage);

      final app = service.getService(DockerComposeService.app)!;
      expect(app.value['image'], equals(newImage));
    });

    test(
      'setImage should produce a clean string without unnecessary backslash escapes',
      () {
        const appImage = r'${APP_NAME}/app:dev';
        service.setImage(DockerComposeService.app, appImage);

        final output = service.toString();

        // The matcher must now account for the single quotes we forced
        expect(
          output,
          contains("image: '\${APP_NAME}/app:dev'"),
          // Wrap in double quotes so single quotes are literal
          reason:
              'The output should contain the image string wrapped in single quotes',
        );

        expect(
          output,
          isNot(contains(r'\/')),
          reason: 'Forward slashes should not be escaped in the YAML output',
        );
      },
    );

    test('removeDependsOn should remove a specific dependency', () {
      // In main template, 'queue' depends on 'app' and 'db'
      expect(service.hasDependency(.queue, .db), isTrue);

      service.removeDependsOn(.queue, .db);

      expect(service.hasDependency(.queue, .db), isFalse);
      expect(service.hasDependency(.queue, .app), isTrue);
    });

    test(
      'removeDependsOn should remove the entire depends_on block if empty',
      () {
        // 'nginx' only depends on 'app'
        expect(service.hasDependency(.nginx, .app), isTrue);

        service.removeDependsOn(.nginx, .app);

        final nginx = service.getService(.nginx)!;
        expect(nginx.value.containsKey('depends_on'), isFalse);
        expect(service.hasDependency(.nginx, .app), isFalse);
      },
    );

    test('removeBuild should remove the build block from a service', () {
      // In main template, 'app' has a build block
      final app = service.getService(.app)!;
      expect(app.value.containsKey('build'), isTrue);

      service.removeBuild(.app);

      final updatedApp = service.getService(.app)!;
      expect(updatedApp.value.containsKey('build'), isFalse);
      // Ensure other properties still exist
      expect(updatedApp.value.containsKey('image'), isTrue);
    });

    test('toString returns the modified YAML string', () {
      service.removeService(.soketi);
      final output = service.toString();
      expect(output, isA<String>());
      expect(output, isNot(contains('soketi:')));
    });
  });
}
