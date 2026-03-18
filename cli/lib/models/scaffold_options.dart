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

class ScaffoldOption {
  final String phpVersion;
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
