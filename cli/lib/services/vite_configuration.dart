import 'dart:io';
import 'package:logging/logging.dart';

class ViteConfigurationService {
  final _log = Logger('ViteConfig');
  final File _file = File('vite.config.js');

  void setupDockerHost() {
    if (!_file.existsSync()) {
      _log.warning('⚠️ vite.config.js not found. Skipping Vite configuration.');
      return;
    }

    _log.info('🔍 Checking vite.config.js for Docker compatibility...');
    String content = _file.readAsStringSync();

    // 1. Check if a 'server' block already exists
    // Use dotAll: true so '.' matches newlines across the block
    final serverRegex = RegExp(r'server\s*:\s*\{.*?\}', dotAll: true);
    final hasServerBlock = serverRegex.hasMatch(content);

    if (hasServerBlock) {
      content = _updateExistingServerBlock(content, serverRegex);
    } else {
      content = _injectNewServerBlock(content);
    }

    _file.writeAsStringSync(content);
    _log.info('🚀 Successfully configured Vite host to 0.0.0.0');
  }

  String _updateExistingServerBlock(String content, RegExp serverRegex) {
    return content.replaceFirstMapped(serverRegex, (match) {
      String block = match.group(0)!;

      // If 'host' exists, update it; otherwise, insert it after the opening '{'
      if (block.contains('host:')) {
        return block.replaceFirst(
          RegExp(r'''host\s*:\s*["'][^"']*["']'''),
          'host: "0.0.0.0"',
        );
      } else {
        return block.replaceFirst('{', '{\n        host: "0.0.0.0",');
      }
    });
  }

  String _injectNewServerBlock(String content) {
    // Standard Laravel vite configs end with });
    // We inject the server block safely before the final closing
    const serverTemplate = '''
    server: {
        host: "0.0.0.0",
        watch: {
            usePolling: true,
        },
    },''';

    if (content.contains('export default defineConfig({')) {
      return content.replaceFirst(
        'export default defineConfig({',
        'export default defineConfig({$serverTemplate',
      );
    }

    // Fallback: search from the end if the standard export isn't found
    final lastIndex = content.lastIndexOf('});');
    if (lastIndex != -1) {
      return content.substring(0, lastIndex) +
          serverTemplate +
          content.substring(lastIndex);
    }

    return content;
  }
}
