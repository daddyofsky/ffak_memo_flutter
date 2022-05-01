import 'dart:io';

class AnsiColor {
  static const int black = 0;
  static const int red = 1;
  static const int green = 2;
  static const int yellow = 3;
  static const int blue = 4;
  static const int magenta = 5;
  static const int cyan = 6;
  static const int white = 7;
  
  static final Map<String, int> _colorMap = {
    'black': black,
    'red': red,
    'green': green,
    'yellow': yellow,
    'blue': blue,
    'magenta': magenta,
    'cyan': cyan,
    'white': white,
  };
  
  static int parse(String code, {bool bold = false}) {
    if (!Ansi.enabled || code == '') {
      return -1;
    }
    if (_colorMap.containsKey(code)) {
      return _colorMap[code] ?? 0;
    }

    if (code.startsWith('#')) {
      code = code.substring(1);
    }

    var r = 0.0, g = 0.0, b = 0.0;
    if (code.length == 3) {
      r = int.parse('0x' + code[0] + code[0]) / 255;
      g = int.parse('0x' + code[1] + code[1]) / 255;
      b = int.parse('0x' + code[2] + code[2]) / 255;
    } else if (code.length == 6) {
      r = int.parse('0x' + code.substring(0, 2)) / 255;
      g = int.parse('0x' + code.substring(2, 4)) / 255;
      b = int.parse('0x' + code.substring(4, 6)) / 255;
    } else {
      return -1;
    }

    return 36 * (5 * r).toInt() + 6 * (5 * g).toInt() + (5 * b).toInt() + 16 + (bold ? 8 : 0);
  }
}

class Ansi {

  static const String ansiEscape = '\x1B[';
  static const String ansiReset = '\x1B[0m';
  static const String ansiForeground = '\x1B[38;5;';
  static const String ansiResetForeground = '\x1B[39m';
  static const String ansiBackground = '\x1B[48;5;';
  static const String ansiResetBackground = '\x1B[49m';
  static const String ansiColor = '\x1B[0m';

  static bool enabled = Platform.isIOS ? false : true;
  final String text;
  late int _color;
  late int _bg;
  final bool bold;

  Ansi(this.text, String color, {String bg = '', this.bold = false}) {
    _color = AnsiColor.parse(color);
    _bg = AnsiColor.parse(color);
  }

  Ansi.black(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.black, _bg = AnsiColor.parse(bg);
  Ansi.red(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.red, _bg = AnsiColor.parse(bg);
  Ansi.green(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.green, _bg = AnsiColor.parse(bg);
  Ansi.yellow(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.yellow, _bg = AnsiColor.parse(bg);
  Ansi.blue(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.blue, _bg = AnsiColor.parse(bg);
  Ansi.magenta(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.magenta, _bg = AnsiColor.parse(bg);
  Ansi.cyan(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.cyan, _bg = AnsiColor.parse(bg);
  Ansi.white(this.text, {String bg = '', this.bold = false}) : _color = AnsiColor.white, _bg = AnsiColor.parse(bg);

  @override
  String toString() {
    if (!enabled) {
      return text;
    }

    final sb = StringBuffer();
    if (_color != -1) {
      sb.write('$ansiForeground${_color}m');
    }
    if (_bg != -1) {
      sb.write('$ansiForeground${_bg}m');
    }

    sb.write(text);
    sb.write(ansiReset);

    return sb.toString();
  }

}