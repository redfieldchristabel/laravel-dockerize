import 'dart:io';

import 'package:cli/models/scaffold_options.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';

class GitignoreService {
  final _log = Logger('GitignoreService');
  final FileSystem fs;

  GitignoreService({FileSystem? fs}) : fs = fs ?? const LocalFileSystem();

  /// Adds a [path] to the .gitignore file if it doesn't already exist.
  ///
  /// An optional [comment] can be provided to describe the entry.
  void addPath(String path, {String? comment}) {
    final file = fs.file('.gitignore');

    if (!file.existsSync()) {
      _log.warning('⚠️ .gitignore not found. Skipping...');
      return;
    }

    final content = file.readAsStringSync();
    final trimmedPath = path.trim();

    // Check if the path is already ignored to avoid duplicates
    final lines = content.split('\n').map((line) => line.trim());
    if (lines.contains(trimmedPath)) {
      _log.finest('Path "$trimmedPath" already exists in .gitignore.');
      return;
    }

    _log.info('➕ Adding "$trimmedPath" to .gitignore...');

    final buffer = StringBuffer();

    // 1. Ensure we start on a new line if the file isn't empty and doesn't end with one
    if (content.isNotEmpty && !content.endsWith('\n')) {
      buffer.writeln();
    }

    // 2. Add an extra blank line if there's a comment, for better readability
    if (comment != null && content.isNotEmpty) {
      buffer.writeln();
    }

    // 3. Write the comment if provided
    if (comment != null) {
      buffer.writeln('# $comment');
    }

    // 4. Write the path
    buffer.writeln(trimmedPath);

    // Append the new entry to the end of the file
    file.writeAsStringSync(
      buffer.toString(),
      mode: FileMode.append,
      flush: true,
    );
  }

  /// Adds the database mount path to .gitignore based on the selected database.
  void addDbMountPath(Database database) {
    switch (database) {
      case Database.sqlite:
        _log.finest('SQLite selected. No additional path to ignore.');
        break;
      case Database.mysql:
        addPath('/mysql', comment: 'MySQL database data');
        break;
      case Database.postgres:
        addPath('/postgres', comment: 'Postgres database data');
        break;
      case Database.mariadb:
        addPath('/mariadb', comment: 'MariaDB database data');
        break;
    }
  }
}
