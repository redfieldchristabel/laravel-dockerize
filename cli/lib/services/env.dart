import 'dart:io';

import 'package:cli/models/scaffold_options.dart';
import 'package:logging/logging.dart';

class EnvService {
  final _log = Logger('EnvService');

  bool envExist = false;

  bool get checkEnv {
    _log.finest('Checking if .env exist');
    if (!envExist) _log.warning('Skipping, .env not propagate');
    return envExist;
  }

  void configure(ScaffoldOption option) {
    _log.info('📄 Configuring .env file...');
    createFile();
    configureDatabase(option);
    configureSession();
    configureBroadcastConnection();
    configureQueueConnection();
    configureCacheStore();
    configureMailer();
    configureRedis();
    configurePusher(option);
    _log.info('🚀 .env file configured successfully!');
  }

  void createFile() {
    _log.info('Creating env file');
    _log.finest('Checking if existing .env exist');

    if (File('.env').existsSync()) {
      _log.info('ℹ️ .env already exists. Skipping...');
      envExist = true;
      return;
    }

    _log.info('📄 .env not found. Creating from .env.example...');
    if (File('.env.example').existsSync()) {
      File('.env.example').copySync('.env');
      _log.info('🚀 .env created successfully!');
      envExist = true;
    } else {
      _log.warning('⚠️ .env.example not found. Skipping .env creation.');
    }
  }

  void configureDatabase(ScaffoldOption option) {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env database configuration...');

    if (option.database == Database.sqlite) {
      _log.finest('Setting DB_CONNECTION to sqlite');
      content = _replaceEnvValue(content, 'DB_CONNECTION', 'sqlite');
      content = _commentOutEnvKey(content, 'DB_HOST');
      content = _commentOutEnvKey(content, 'DB_PORT');
      content = _commentOutEnvKey(content, 'DB_DATABASE');
      content = _commentOutEnvKey(content, 'DB_USERNAME');
      content = _commentOutEnvKey(content, 'DB_PASSWORD');
    } else {
      content = _replaceEnvValue(content, 'DB_HOST', 'db');
      content = _replaceEnvValue(
        content,
        'DB_CONNECTION',
        option.database.connectionName,
      );
    }
    finish(content);
    _log.info('🚀 .env database configuration updated!');
  }

  void configureSession() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env session configuration...');
    content = _replaceEnvValue(content, 'SESSION_DRIVER', 'redis');
    finish(content);
    _log.info('🚀 .env session configuration updated!');
  }

  void configureBroadcastConnection() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env broadcast connection configuration...');
    content = _replaceEnvValue(content, 'BROADCAST_CONNECTION', 'pusher');
    finish(content);
    _log.info('🚀 .env broadcast connection configuration updated!');
  }

  void configureQueueConnection() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env queue connection configuration...');
    content = _replaceEnvValue(content, 'QUEUE_CONNECTION', 'redis');
    finish(content);
    _log.info('🚀 .env queue connection configuration updated!');
  }

  void configureCacheStore() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env cache store configuration...');
    content = _replaceEnvValue(content, 'CACHE_STORE', 'redis');
    finish(content);
    _log.info('🚀 .env cache store configuration updated!');
  }

  void configureRedis() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env redis configuration...');
    content = _replaceEnvValue(content, 'REDIS_CLIENT', 'phpredis');
    content = _replaceEnvValue(content, 'REDIS_HOST', 'redis');
    finish(content);
    _log.info('🚀 .env redis configuration updated!');
  }

  void configureMailer() {
    if (!checkEnv) return;

    var (content, finish) = getContent();

    _log.info('Updating .env mailer configuration...');
    content = _replaceEnvValue(content, 'MAIL_MAILER', 'smtp');
    content = _replaceEnvValue(content, 'MAIL_SCHEME', 'null');
    content = _replaceEnvValue(content, 'MAIL_HOST', 'mailpit');
    content = _replaceEnvValue(content, 'MAIL_PORT', '1025');
    finish(content);
    _log.info('🚀 .env mailer configuration updated!');
  }

  void configurePusher(ScaffoldOption option) {
    if (!checkEnv) return;

    if (option.webSocket != WebSocketTech.soketi) {
      _log.info('ℹ️ WebSocket is not Soketi. Skipping Pusher configuration.');
      return;
    }

    var (content, finish) = getContent();

    _log.info('Updating .env pusher configuration for soketi...');
    content = _replaceEnvValue(content, 'PUSHER_APP_ID', 'app-id');
    content = _replaceEnvValue(content, 'PUSHER_APP_KEY', 'app-key');
    content = _replaceEnvValue(content, 'PUSHER_APP_SECRET', 'app-secret');
    content = _replaceEnvValue(content, 'PUSHER_HOST', 'soketi');
    content = _replaceEnvValue(content, 'PUSHER_PORT', '6001');
    content = _replaceEnvValue(content, 'PUSHER_SCHEME', 'http');

    _log.info('Updating .env vite pusher configuration...');
    content = _replaceEnvValue(
      content,
      'VITE_PUSHER_APP_KEY',
      '"\${PUSHER_APP_KEY}"',
    );
    content = _replaceEnvValue(content, 'VITE_PUSHER_HOST', '"localhost"');
    content = _replaceEnvValue(content, 'VITE_PUSHER_PORT', '"80"');
    content = _replaceEnvValue(content, 'VITE_PUSHER_SCHEME', '"http"');

    finish(content);
    _log.info('🚀 .env pusher configuration updated!');
  }

  (String, void Function(String content) finish) getContent() {
    final file = File('.env');
    return (
      file.readAsStringSync(),
      (String content) => file.writeAsStringSync(content),
    );
  }

  String _replaceEnvValue(String content, String key, String value) {
    _log.finest('Setting $key to $value');
    final regExp = RegExp('^$key=.*', multiLine: true);
    if (regExp.hasMatch(content)) {
      return content.replaceAll(regExp, '$key=$value');
    }
    return '$content\n$key=$value';
  }

  String _commentOutEnvKey(String content, String key) {
    final regExp = RegExp('^$key=.*', multiLine: true);
    return content.replaceAll(regExp, '# $key=');
  }
}
