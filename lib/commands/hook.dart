import 'package:args/command_runner.dart';
import 'dart:isolate';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:git/git.dart';
import 'package:dart_console/dart_console.dart';

class HookCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize gitmoji as a commit hook';

  @override
  Future run() async {
    var currentDir = p.current;
    if (!await GitDir.isGitDir(currentDir)) {
      Console().writeErrorLine(
          'Current directory is not a git directory. Initialize a repository first.');
      return;
    }

    final gitDir = await GitDir.fromExisting(currentDir, allowSubdirectory: true);
    final hookDir = Directory(p.join(gitDir.path,'.git','hooks'));
    hookDir.createSync(recursive: true);
    var hookPath = p.join(hookDir.path, 'prepare-commit-msg');
    if (File(hookPath).existsSync()) {
      Console().writeErrorLine('A prepare-commit-msg hook already exists.');
      return;
    }

    final scriptUri = Uri.parse('package:gitmoji/git-hook.sh');
    final uri = await Isolate.resolvePackageUri(scriptUri);
    if (uri != null) {
      await File.fromUri(uri).copy(hookPath);
    }
    print('Created commit hook');

    await gitDir.runCommand(['config', 'alias.cm', 'commit --no-edit']);
    print('Created commit alias ("git cm")');
  }
}