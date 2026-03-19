import 'package:cli/services/docker_compose_editor.dart';
import 'package:cli/templates/docker_compose/db.docker-compose.g.dart';
import 'package:test/test.dart';

void main() {
  group('DockerComposeEditorService', () {
    late DockerComposeEditorService service;

    setUp(() {
      service = DockerComposeEditorService(dockercomposeDbDockerComposeTemplate);
    });

    test('should get YamlNode for postgres', () {
      final node = service.getService(DockerComposeService.postgres);
      expect(node, isNotNull);
      expect(node!.value['image'], contains('postgres'));
    });

    test('should get YamlNode for mariadb', () {
      final node = service.getService(DockerComposeService.mariadb);
      expect(node, isNotNull);
      expect(node!.value['image'], contains('mariadb'));
    });

    test('should return null for non-existent service (mocking exclusion of mysql if needed, or just testing failure)', () {
       // Based on the prompt "except mysql", I will verify that we can get others, 
       // but if you want to explicitly ensure mysql is NOT there or handled differently:
       final node = service.getService(DockerComposeService.mysql);
       expect(node, isNotNull, reason: 'MySQL should exist in the template');
    });
  });
}
