import 'package:dcli/dcli.dart';

import 'unpubd_paths.dart';
import 'unpubd_settings.dart';

// ignore: avoid_classes_with_only_static_members
class EnvFile {
  static void create() {
    final s = UnpubdSettings();

    /// Create the .env for docker-compose to get its environment from.
    UnpubdPaths().pathToDotEnv
      ..write('MONGO_INITDB_ROOT_USERNAME=root')
      ..append('MONGO_INITDB_ROOT_PASSWORD=${s.mongoRootPassword}')
      ..append('MONGO_INITDB_DATABASE=${s.mongoDatabase}')
      ..append('MONGO_DATABASE=${s.mongoDatabase}')
      ..append('MONGO_ROOT_USERNAME=root')
      ..append('MONGO_ROOT_PASSWORD=${s.mongoRootPassword}')
      ..append('MONGO_DATABASE=${s.mongoDatabase}')
      ..append('MONGO_HOST=mongodb')
      ..append('MONGO_PORT=27017')
      ..append('TZ=${DateTime.now().timeZoneName}')
      ..append('GOOGLE_SECRET_NAME=${s.googleSecretName}')
      ..append('GOOGLE_SECRET_REFRESH_TOKEN=${s.googleSecretRefreshToken}')
      ..append(
          // ignore: lines_longer_than_80_chars
          'GOOGLE_SERVICE_ACCOUNT_JSON_BASE64=${s.googleServiceAccountJsonBase64}')
      ..append('PRESHARED_ALLOWED_TOKENS=${s.presharedAllowedTokens}')
      ..append('PRESHARED_UPLOAD_EMAIL=${s.presharedUploadEmail}')
      ..append('PRESHARED_UPLOAD_TOKENS=${s.presharedUploadTokens}')
      ..append('')
      ..append('UNPUBD_HOST=${s.unpubHost}')
      ..append('UNPUBD_PORT=${s.unpubPort}');
  }
}
