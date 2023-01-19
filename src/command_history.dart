import "dart:io";

import "package:tabular/tabular.dart";

import 'color.dart';

class CommandHistory {
  bool _escape = false;
  final List<LogItem> _log = [];
  String _fileName = "";
  final List<List<String>> _commands = [
    ["Command", "Description"],
    [
      "!close",
      "Saves command line history to a file and closes the history listener.  ATTENTION: THIS IS THE ONLY WAY TO SAVE PROGRESS"
    ],
    ["!history", "Prints session history log to the command line."],
    ["!help", "Displays list of commands to the command line."]
  ];

  late final int _saveCount;
  int _iterate = 1;

  CommandHistory() {
    this._saveCount = 5;
  }
  CommandHistory.withSaveCount(this._saveCount);

  Future<String> _runCommand(String command, List<String> arguments) async {
    switch (command) {
      case "cls":
        if (Platform.isIOS) {
          print("\x1B[2J\x1B[0;0H");
        }
        break;
      case "clear":
        if (Platform.isWindows) {
          print("\x1B[2J\x1B[0;0H");
        }
        break;
    }

    var result = await Process.run(command, arguments, runInShell: true);
    var text = await result.stdout;
    stdout.writeln(text);
    return text;
  }

  void run() async {
    while (!_escape) {
      stdout.write("> ");
      var cmd = stdin.readLineSync();
      var tokens = cmd!.split(' ');

      if (tokens[0].contains("!")) {
        _escape =
            _runCliCommand(tokens[0], tokens.length >= 2 ? tokens[1] : null);
      } else {
        _log.add(LogItem(DateTime.now(),
            await _runCommand(tokens[0], tokens.sublist(1)), cmd));
      }

      _update();
    }
  }

  bool _runCliCommand(String cmd, String? arg) {
    var code = cmd.replaceAll('!', '');

    switch (code) {
      case "close":
        if (arg == null) {
          _save();
        }
        return true;
      case "save":
        _save();
        return false;
      case "history":
        print(_printHistory());
        return false;
      case "help":
        _printHelp();
        return false;
      default:
        stderr.writeln(
            ColorObject.colorText("Unrecognized internal command.", "red"));
        return false;
    }
  }

  void _save() {
    final date = DateTime.now();

    stdout.writeln(ColorObject.colorText("Saving...", "cyan"));

    _fileName = "${date.year}-${date.month}-${date.day}.txt";

    var file = File(_fileName);

    file.writeAsStringSync(_printHistory(), mode: FileMode.append);
  }

  void _printHelp() {
    stdout.writeln("Usage: ./dood [NUMBER OF COMMANDS BETWEEN AUTO SAVES]");
    stdout.writeln(tabular(_commands, border: Border.all));
  }

  String _printHistory() {
    String result = "";
    for (var log in _log) {
      var time = log.time.toString().split('.')[0];
      result +=
          "\n${time}\n\"${log.command}\"\n\n${log.content}\n${'-' * time.length}";
    }

    return result;
  }

  void _update() {
    _saveIteration();
  }

  void _saveIteration() {
    if (_iterate >= _saveCount) {
      _iterate = 1;
      _save();
      return;
    }

    _iterate++;
  }
}

class LogItem {
  late DateTime time;
  late String content;
  late String command;

  LogItem(this.time, this.content, this.command);
}
