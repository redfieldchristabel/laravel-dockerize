import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class ManageDockerComposeService {
  final String content;
  late final YamlEditor editor = YamlEditor(content);

  final _log = Logger('DockerComposeEditorService');

  ManageDockerComposeService(this.content);

  /// Returns the definition of a specific service.
  YamlNode? getService(DockerComposeService service) {
    try {
      return editor.parseAt(['services', service.name]);
    } catch (e) {
      _log.finest('Service $service not found');
      return null;
    }
  }

  /// Checks if a service has a specific dependency.
  bool hasDependency(
    DockerComposeService service,
    DockerComposeService dependency,
  ) {
    try {
      final dependsOn =
          editor.parseAt(['services', service.name, 'depends_on']).value
              as List?;
      return dependsOn?.contains(dependency.name) ?? false;
    } catch (e) {
      return false;
    }
  }

  void removeService(DockerComposeService service) {
    _log.finest('Removing service: ${service.name}');
    editor.remove(['services', service.name]);
  }

  bool tryRemoveService(DockerComposeService service) {
    try {
      removeService(service);
      return true;
    } catch (_) {
      return false;
    }
  }

  void setService(DockerComposeService service, YamlNode definition) {
    _log.finest('Setting service: ${service.name}');
    editor.update(['services', service.name], definition);
  }

  /// Sets or updates the 'image' property for a specific service.
  void setImage(DockerComposeService service, String image) {
    _log.finest('Setting image for ${service.name} to: $image');

    // Wrap the string to control how it is rendered in YAML
    final wrappedImage = YamlScalar.wrap(
      image,
      style: ScalarStyle
          .SINGLE_QUOTED, // PLAIN usually removes the escape backslashes
    );

    editor.update(['services', service.name, 'image'], wrappedImage);
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

  void removeBuild(DockerComposeService service) {
    _log.finest('Removing build for ${service.name}');
    editor.remove(['services', service.name, 'build']);
  }

  @override
  String toString() {
    return editor.toString();
  }
}

enum DockerComposeService {
  app,
  db,
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
  reverb,
  postgres,
  mariadb,
}
