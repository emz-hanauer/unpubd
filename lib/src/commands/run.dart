import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:unpub/unpub.dart';

import '../unpubd_paths.dart';
import 'run_args.dart';

///
class RunCommand extends Command<void> {
  ///
  RunCommand() {
    RunArgs().build(argParser);
  }

  @override
  String get description => 'Run unpub within the docker container.';

  @override
  String get name => 'run';

  /// This command is only used within the docker container.
  @override
  bool get hidden => true;

  @override
  void run() {
    RunArgs().parse(argResults!);
    _run();
  }

  Future<void> _run() async {
    final db = await waitForMongo();

    await runUnpubd(db);
  }

  Future<Db> waitForMongo() async {
    Db? db;
    var connected = false;
    while (!connected) {
      try {
        db = Db(mongoRootUri());
        await db.open(); // make sure the MongoDB connection opened
        connected = true;

        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        print('waiting for mongodb to start: $e');
        sleep(2);
      }
    }

    return db!;
  }

  String getDatabaseName() {
    final database = env['MONGO_DATABASE'] ?? 'dart_pub';
    return database;
  }

  String mongoRootUri() {
    final rootUsername = env['MONGO_ROOT_USERNAME'];
    final rootPassword = env['MONGO_ROOT_PASSWORD'];
    final host = env['MONGO_HOST'] ?? 'mongodb';
    final port = env['MONGO_PORT'] ?? '27017';
    final uri =
        'mongodb://$rootUsername:$rootPassword@$host:$port/unpubd?authSource=admin'; //
    //$database';
    print('connecting with $uri');
    return uri;
  }

  Future<void> runUnpubd(Db db) async {
    if (!exists(UnpubdPaths().pathToPackages)) {
      createDir(UnpubdPaths().pathToPackages, recursive: true);
    }
    final app = App(
      metaStore: MongoStore(db),
      packageStore: FileStore(UnpubdPaths().pathToPackages),
      googleSecretName: env['GOOGLE_SECRET_NAME'],
      googleSecretRefreshToken: env['GOOGLE_SECRET_REFRESH_TOKEN'],
      googleServiceAccountJsonBase64: env['GOOGLE_SERVICE_ACCOUNT_JSON_BASE64'],
      presharedAllowedTokens: env['PRESHARED_ALLOWED_TOKENS']?.split(','),
      presharedUploadEmail: env['PRESHARED_UPLOAD_EMAIL'],
      presharedUploadTokens: env['PRESHARED_UPLOAD_TOKENS']?.split(','),
    );

    final unpubHost = env['UNPUBD_HOST'] ?? '0.0.0.0';
    final unpubPort = env['UNPUBD_PORT'] ?? '4000';

    final server = await app.serve(unpubHost, int.parse(unpubPort));
    print('Serving at http://${server.address.host}:${server.port}');
  }
}
