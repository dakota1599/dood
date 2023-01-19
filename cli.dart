import "dart:io";

import "package:tabular/tabular.dart";

import "./models.dart";

void main(List<String> arguments) {
  var history = CommandHistory();
  stdout.writeln(ColorObject.colorText(
      "Recording your command line interactions now...", "green"));
  history.run();
}

class LogItem {
  late DateTime time;
  late String content;

  LogItem(this.time, this.content);
}

class CommandHistory {
  late bool _escape = false;
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

  Future<String> _runCommand(String command, List<String> arguments) async {
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
        _escape = _runCliCommand((tokens[0]));
        continue;
      }

      _log.add(LogItem(
          DateTime.now(), await _runCommand(tokens[0], tokens.sublist(1))));
    }
  }

  bool _runCliCommand(String cmd) {
    var code = cmd.replaceAll('!', '');

    switch (code) {
      case "close":
        _save();
        return true;
      case "history":
        print(_printHistory(newFile: true));
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

  void _save() async {
    bool newFile = _fileName == "";
    final date = DateTime.now();
    if (newFile) {
      _fileName = "${date.year}-${date.month}-${date.day}.txt";
    }

    var file = File(_fileName);

    await file.writeAsString(_printHistory(newFile: newFile),
        mode: FileMode.append);

    return;
  }

  void _printHelp() {
    stdout.writeln(tabular(_commands, border: Border.all));
  }

  String _printHistory({bool newFile = false}) {
    List<List<String>> table = [];

    if (newFile) {
      table.add(["Time", "Item"]);
    }

    for (var log in _log) {
      table.add([log.time.toIso8601String(), log.content]);
    }

    return tabular(table,
        format: {"Time": (value) => value.split(".")[0]},
        border: Border.vertical,
        markdownAlign: true);
  }
}
