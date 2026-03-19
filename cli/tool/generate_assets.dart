import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final templatesDir = Directory('templates');
  final outputDir = Directory('lib/templates');

  if (!templatesDir.existsSync()) {
    print('Error: templates directory not found');
    return;
  }

  // Clear previous generated files (*.g.dart) only
  if (outputDir.existsSync()) {
    for (final entity in outputDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.g.dart')) {
        entity.deleteSync();
      }
    }
  } else {
    outputDir.createSync(recursive: true);
  }

  for (final entity in templatesDir.listSync(recursive: true)) {
    if (entity is! File) continue;

    final relative = p.relative(entity.path, from: templatesDir.path);
    final dir = p.dirname(relative);
    final base = p.basename(relative);

    // Special files like Dockerfile or .env should keep name as-is
    String namePart;
    if (base.contains('.') && !isSpecialFile(base)) {
      namePart = p.withoutExtension(base);
    } else {
      namePart = base;
    }

    // Only include directory in variable if it's different from file name
    String variableBase;
    final dirName = dir == '.'
        ? ''
        : p.basename(dir).replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final fileNameNormalized = namePart
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase();

    if (dirName.isEmpty || dirName == fileNameNormalized) {
      variableBase = namePart; // avoid duplication
    } else {
      variableBase = p.join(dirName, namePart);
    }

    final variableName = '${toCamelCase(variableBase)}Template';

    // Output path in lib/templates keeping folder structure
    final outputRelative = p.join(dir, '${namePart.toLowerCase()}.g.dart');
    final outputPath = p.join(outputDir.path, outputRelative);

    final outputFile = File(outputPath);
    outputFile.parent.createSync(recursive: true);

    final content = entity.readAsStringSync();

    outputFile.writeAsStringSync('''
/// GENERATED CODE - DO NOT MODIFY
library;

const $variableName = r"""
$content
""";
''');

    print('Generated: $outputPath (Variable: $variableName)');
  }
}

/// Convert path + filename to camelCase
String toCamelCase(String path) {
  final parts = path
      .split(RegExp(r'[^a-zA-Z0-9]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';

  final first = parts.first.toLowerCase();
  final rest = parts
      .skip(1)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase())
      .join();
  return '$first$rest';
}

/// Convert path to a valid Dart library name
String toLibraryName(String path) {
  return path
      .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .toLowerCase();
}

/// Special files that should keep their full name for the variable
bool isSpecialFile(String filename) {
  const special = ['Dockerfile', '.env'];
  return special.contains(filename);
}
