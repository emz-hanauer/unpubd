/// dcli script generated by:
/// dcli create docker_push.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///
///
///import 'dart:io';

import 'dart:io';
import 'package:path/path.dart'; 

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import '../env_file.dart';
import '../unpubd_paths.dart';
import '../unpubd_settings.dart';
import '../util/log.dart';

///
class PullCommand extends Command<void> {
  ///
  PullCommand();

  @override
  String get description => 'Pulls the latest docker containers.';

  @override
  String get name => 'pull';

  @override
  void run() {
    UnpubdSettings.load();
    if (!exists(UnpubdSettings.pathToSettings)) {
      logerr(red('''You must run 'unpubd install' first.'''));
      exit(1);
    }
    pull();
  }

  static void pull() {
    EnvFile.create();
    print('Pulling the latest docker containers');
    'docker-compose pull'
        .start(workingDirectory: dirname(UnpubdPaths().pathToDockerCompose));

    // final images = Images().findAllByName('noojee/unpubd');

    // if (images.isEmpty) {
    //   printerr(
    //       red('Somethi  ng went wrong! Unable to find the "unpubd" image'));
    //   exit(1);
    // }

    // print('Pulled unpubd version: ${container.image!.fullname}');
  }
}
