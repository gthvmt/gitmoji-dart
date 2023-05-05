import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chalkdart/chalk_x11.dart';
import 'package:dart_console/dart_console.dart';
import 'package:chalkdart/chalk.dart';

class Choice<T> {
  final List<T> options;
  final String Function(T) formatter;
  final int? displayLimit;
  final String prompt;
  final bool wrap;
  final StringBuffer _buffer = StringBuffer();
  final _console = Console();
  int selection;

  Choice(String prompt, this.options,
      {this.formatter = _defaultFormatter,
      this.displayLimit,
      this.wrap = true,
      this.selection = 0})
      : prompt = '${chalk.green('?')} $prompt: ';

  static String _defaultFormatter(dynamic x) => x.toString();

  // for some reason if we redraw the buffer after clearing it the previous content 'bleeds through'
  // at least this happens in the windows terminal
  // this method aims to fix this issue by overwriting the content with a blank string before clearing
  void _clear() {
    var pos = _console.cursorPosition;
    var lines = LineSplitter().convert(_buffer.toString());
    var blank = StringBuffer();
    for (var line in lines) {
      blank.writeln(' ' * (line.length + 1));
    }
    _console.write(blank.toString());
    _console.cursorPosition = pos;
    _console.eraseCursorToEnd();
  }

  Future<T?> choose() async {
    _disableStdIn();
    var search = '';
    _console.write(prompt);
    var posWithoutSearch = _console.cursorPosition!;
    var searchHint = true;
    while (true) {
      _console.cursorPosition = posWithoutSearch;
      _clear();
      _buffer.clear();

      _console.write(search.isEmpty && searchHint
          ? chalk.greyX11('(Use arrow keys or type to search)')
          : search);
      var posWithSearch = _console.cursorPosition;

      _buffer.write('\n');

      var displayedOptions = options;

      if (search.isNotEmpty) {
        displayedOptions = displayedOptions
            .where((x) => formatter(x).contains(search))
            .toList();
        selection = min(displayedOptions.length - 1, selection);
      }

      final limit = displayLimit == null
          ? displayedOptions.length
          : min(displayLimit!, displayedOptions.length);

      var selectorPos = limit ~/ 2 - (limit.isEven ? 1 : 0);

      displayedOptions = _rotateList(displayedOptions, selection - selectorPos);

      for (var i = 0; i < limit; i++) {
        var isSelection = i == selectorPos;
        if (isSelection) {
          _buffer.writeln(chalk.blue('❯ ${formatter(displayedOptions[i])}'));
        } else {
          _buffer.writeln('  ${formatter(displayedOptions[i])}');
        }
      }
      if (limit < displayedOptions.length) {
        _buffer
            .write(chalk.greyX11('(Move up and down to reveal more choices)'));
      }

      // write debug output here
      // _buffer.write(posWithSearch);

      _console.write(_buffer.toString());
      _console.cursorPosition = posWithSearch;

      final key = _console.readKey();
      searchHint = false;
      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.escape:
          case ControlCharacter.ctrlC:
            _resetStdIn();
            return null;
          case ControlCharacter.enter:
            var choice = displayedOptions[selectorPos];
            _console.cursorPosition = posWithoutSearch;
            _clear();
            _console.write('${chalk.blue(formatter(choice))}\n');
            _resetStdIn();
            return choice;
          case ControlCharacter.arrowUp:
            selection = wrap
                ? (selection = (selection - 1) % displayedOptions.length).abs()
                : max(0, --selection);
            break;
          case ControlCharacter.arrowDown:
            selection = wrap
                ? selection = (selection + 1) % displayedOptions.length
                : min(displayedOptions.length - 1, selection + 1);
            break;
          case ControlCharacter.backspace:
            search = search.substring(0, max(search.length - 1, 0));
            break;
          case ControlCharacter.ctrlU:
            search = '';
            break;
          default:
            break;
        }
      } else {
        search += key.char;
      }
    }
  }

  List<T> _rotateList(List<T> list, int v) {
    if (list.isEmpty) return list;
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  void _disableStdIn() {
    if (stdin.hasTerminal) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    }
  }

  void _resetStdIn() {
    if (stdin.hasTerminal) {
      // lineMode must be true to set echoMode in Windows
      // see https://github.com/dart-lang/sdk/issues/28599
      stdin.lineMode = true;
      stdin.echoMode = true;
    }
  }
}
