import '../utils/prompts.dart';

class ScaffoldOption {
  final PhpVersion phpVersion;
  final bool useOctane;
  final bool isFilament;
  final Database database;
  final WebSocketTech webSocket;
  final BaseImage baseImage;
  final bool useVite;
  final bool productionReady;

  ScaffoldOption({
    required this.phpVersion,
    required this.useOctane,
    required this.isFilament,
    required this.database,
    required this.webSocket,
    required this.baseImage,
    required this.useVite,
    required this.productionReady,
  });
}

enum PhpVersion with EnumValue {
  v8_4,
  v8_3,
  v8_2,
  v8_1;

  @override
  String get value => switch (this) {
    PhpVersion.v8_1 => '8.1',
    PhpVersion.v8_2 => '8.2',
    PhpVersion.v8_3 => '8.3',
    PhpVersion.v8_4 => '8.4',
  };
}

enum Database {
  sqlite,
  mysql,
  postgres,
  mariadb;

  String get connectionName => switch (this) {
    Database.sqlite => 'sqlite',
    Database.postgres => 'pgsql',
    Database.mariadb => 'mariadb',
    _ => 'mysql',
  };
}

enum WebSocketTech { soketi, reverb }

enum BaseImage { debian, alpine }
