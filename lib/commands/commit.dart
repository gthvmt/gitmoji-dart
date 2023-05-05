import 'package:args/command_runner.dart';
import 'package:dart_console/dart_console.dart';
import 'package:git/git.dart';
import 'dart:io';

import 'package:gitmoji/gitmoji.dart';
import 'dart:convert';
import 'package:gitmoji/prompts/choice.dart';
import 'package:gitmoji/prompts/text.dart';
import 'package:path/path.dart' as p;

class CommitCommand extends Command {
  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  final name = 'commit';
  @override
  final description = 'Interactively commit using the prompts';

  CommitCommand() {
    argParser.addOption('title', abbr: 't');
    argParser.addOption('message', abbr: 'm');
    argParser.addOption('scope', abbr: 's');
  }

  @override
  Future run() async {
    var title = argResults!['title'] as String?;
    var message = argResults!['message'] as String?;
    var scope = argResults!['scope'] as String?;
    final gitmojis = await _getGitmojis();
    var gitmoji =
        await Choice('Choose a gitmoji', gitmojis.toList(), displayLimit: 7)
            .choose();
    if (gitmoji == null) {
      return;
    }
    title =
        await Text('Enter the commit title', maxLength: 47, text: title).ask();
    if (title == null) {
      return;
    }
    message = await Text('Enter the commit message', text: message).ask();
    if (message == null) {
      return;
    }
    var currentDir = p.current;
    if (!await GitDir.isGitDir(currentDir)) {
      Console().writeErrorLine(
          'Current directory is not a git directory. initialize a repository first.');
      return;
    }
    var git = await GitDir.fromExisting(currentDir);
    await git.runCommand([
      'commit',
      '-m ${gitmoji.code}${scope?.isNotEmpty ?? false ? ' ($scope):' : ''} ${title.trim()}',
      if (message.trim().isNotEmpty) '-m ${message.trim()}'
    ]);
  }
}

Future<Iterable<Gitmoji>> _getGitmojis() async {
  final cacheFile = _getCacheFile();
  String rawJson;
  var isCached = false;
  if (!await cacheFile.exists()) {
    await cacheFile.create(recursive: true);
    final uri = Uri.parse('https://gitmoji.dev/api/gitmojis');
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(uri);
    final response = await request.close();
    rawJson = await response.transform(utf8.decoder).join();
    final json = jsonDecode(rawJson);
    rawJson = jsonEncode(json['gitmojis']);
    httpClient.close();
    await cacheFile.writeAsString(rawJson);
  } else {
    isCached = true;
    rawJson = await cacheFile.readAsString();
  }
  try {
    final decodedJson = jsonDecode(rawJson);
    return decodedJson.map<Gitmoji>((gm) => Gitmoji.fromJson(gm));
  } catch (e) {
    if (!isCached) {
      rethrow;
    }
    // cache may have been tampered with?
    await cacheFile.delete();
    return await _getGitmojis();
  }
}

File _getCacheFile() => File(p.join(
    (Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'])!,
    '.gitmoji',
    'gitmojis.json'));
