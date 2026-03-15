import 'package:logging/logging.dart';
import 'package:yaml_edit/yaml_edit.dart';

class DockerComposeEditorService {
  final String content;
  late final YamlEditor editor = YamlEditor(content);

  final _log = Logger('DockerComposeEditorService');

  DockerComposeEditorService(this.content);

  void removeService(DockerComposeService service) {
    _log.finest('Removing service: ${service.name}');
    editor.remove(['services', service.name]);
  }

  void removeDependsOn(
    DockerComposeService service,
    DockerComposeService dependency,
  ) {
    try {
      final dependsOn =
          editor.parseAt(['services', service.name, 'depends_on']).value
              as List?;
      if (dependsOn != null && dependsOn.contains(dependency.name)) {
        _log.finest(
          'Removing dependency: ${dependency.name} from service: ${service.name}',
        );
        final index = dependsOn.indexOf(dependency.name);
        editor.remove(['services', service.name, 'depends_on', index]);

        // If depends_on is empty, remove it entirely
        final updatedDependsOn =
            editor.parseAt(['services', service.name, 'depends_on']).value
                as List;
        if (updatedDependsOn.isEmpty) {
          _log.finest('Removing empty depends_on for service: ${service.name}');
          editor.remove(['services', service.name, 'depends_on']);
        }
      }
    } catch (e) {
      // depends_on might not exist
    }
  }

  @override
  String toString() {
    return editor.toString();
  }
}

enum DockerComposeService {
  app,
  queue,
  scheduler,
  mysql,
  nginx,
  redis,
  phpmyadmin,
  node,
  vite,
  mailpit,
  soketi,
}
