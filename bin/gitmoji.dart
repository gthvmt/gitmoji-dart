import 'package:args/command_runner.dart';
import 'package:gitmoji/commands/commit.dart';
import 'package:gitmoji/commands/hook.dart';

void main(List<String> arguments) {
  CommandRunner('gitmoji', 'A dart implementation of gitmoji-cli')
    ..addCommand(CommitCommand())
    ..addCommand(HookCommand())
    ..run(arguments);
}

Future<void> commit(String x) async {
  print(x);
}
