class ColorObject {
  static String black = "\x1B[30m";
  static String red = "\x1B[31m";
  static String green = "\x1B[32m";
  static String yellow = "\x1B[33m";
  static String blue = "\x1B[34m";
  static String magenta = "\x1B[35m";
  static String cyan = "\x1B[36m";
  static String white = "\x1B[37m";
  static String reset = "\x1B[0m";

  static var colors = {
    "black": black,
    "red": red,
    "green": green,
    "yellow": yellow,
    "blue": blue,
    "magenta": magenta,
    "cyan": cyan,
    "white": white
  };

  static String colorText(String str, String color) {
    if (!colors.containsKey(color)) {
      throw Exception("Unrecognized color code.");
    }
    final selColor = colors[color];
    return "${selColor}${str}${reset}";
  }
}
