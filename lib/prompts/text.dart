import 'package:chalkdart/chalk.dart';
import 'package:dart_console/dart_console.dart';

class Text {
  final String prompt;
  final int? maxLength;
  final Console _console = Console();
  String _text;

  Text(this.prompt, {this.maxLength, String? text}) : _text = text ?? '';

  Future<String?> ask() async {
    onTextUpdated(_text);
    var isCancelled = _console.readLine(
        cancelOnBreak: true,
        cancelOnEscape: true,
        callback: (text, _) => onTextUpdated(text)) == null;
    return isCancelled ? null : _text;
  }

  void onTextUpdated(String newText) {
    _text = newText;
    var lengthIndicator = '[${newText.length}/$maxLength]';
    var displayedPrompt =
        '${chalk.green('?')} $prompt${maxLength != null ? ' ${newText.length > maxLength! ? chalk.red(lengthIndicator) : chalk.green(lengthIndicator)}' : ''}: ';
    _console.cursorPosition = Coordinate(_console.cursorPosition!.row, 0);
    _console.write(displayedPrompt + newText);
  }
}
