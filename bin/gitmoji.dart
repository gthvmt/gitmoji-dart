import 'package:args/command_runner.dart';
import 'package:gitmoji/commands/commit.dart';

const commitOption = 'commit';

void main(List<String> arguments) {
  CommandRunner('gitmoji', 'A dart implementation of gitmoji-cli')
    ..addCommand(CommitCommand())
    ..run(arguments);
}

Future<void> commit(String x) async {
  print(x);
}
