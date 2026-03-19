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

    test('removeService should remove the service from yaml', () {
      expect(service.toString(), contains('phpmyadmin:'));

      service.removeService(.phpmyadmin);

      expect(service.toString(), isNot(contains('phpmyadmin:')));
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

    test('removeDependsOn should remove a specific dependency', () {
      // In main template, 'queue' depends on 'app' and 'db'
      expect(service.toString(), contains('depends_on:'));

      service.removeDependsOn(.queue, .db);

      final queue = service.getService(.queue)!;
      final dependsOn = queue.value['depends_on'] as List;
      expect(dependsOn, isNot(contains('db')));
      expect(dependsOn, contains('app'));
    });

    test(
      'removeDependsOn should remove the entire depends_on block if empty',
      () {
        // 'nginx' only depends on 'app'
        service.removeDependsOn(.nginx, .app);

        final nginx = service.getService(.nginx)!;
        expect(nginx.value.containsKey('depends_on'), isFalse);
      },
    );

    test('toString returns the modified YAML string', () {
      service.removeService(.soketi);
      final output = service.toString();
      expect(output, isA<String>());
      expect(output, isNot(contains('soketi:')));
    });
  });
}
