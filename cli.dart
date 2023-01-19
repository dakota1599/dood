import 'dart:io';

import './src/command_history.dart';
import 'src/color.dart';

void main(List<String> arguments) {
  CommandHistory history = arguments.isNotEmpty
      ? CommandHistory.withSaveCount(int.parse(arguments[0]))
      : CommandHistory();
  stdout.writeln(ColorObject.colorText(
      "(Dood) Recording command line interactions now...", "green"));
  history.run();
}
