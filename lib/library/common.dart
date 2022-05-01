import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/material.dart';

import 'ansi.dart';

final debug = Common.debug;
const ansiColorDisabled = false;

class Common {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static initResource() {
    initDateFormatLocale('ko');
  }

  static initDateFormatLocale([String locale = 'ko']) {
    initializeDateFormatting(locale);
  }

  static bool _isOnError = false;
  static Future error(String text, {String title = 'ERROR', String ok = '닫기', BuildContext? context}) async {

    debug('red:Common.error', title + ' : ' + text);
    if (_isOnError) {
      debug('SKIP : another error is on');
      return;
    }
    _isOnError = true;

    Completer c = Completer<void>();
    showDialog(
        context: context ?? navigatorKey.currentContext!,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              child: Text(ok),
              onPressed: () {
                Common.popPage(context); // dismiss dialog
                c.complete();
              },
            )
          ],
        )
    ).then((_) {
      _isOnError = false;
    });

    return c.future;
  }

  static Future confirm(String text, {String? title, String ok = '확인', String cancel = '취소', BuildContext? context}) async {
    return showDialog(
        context: context ?? navigatorKey.currentContext!,
        builder: (BuildContext context) => AlertDialog(
          title: title != null ? Text(title) : null,
          content: Text(text),
          actions: [
            TextButton(
              child: Text(cancel),
              onPressed: () {
                Common.popPage(context, false); // dismiss dialog and return false
              },
            ),
            TextButton(
              child: Text(ok),
              onPressed: () {
                Common.popPage(context, true); // dismiss dialog and return true
              },
            )
          ],
        )
    );
  }

  static toast(String text, {int delay = 3000}) {
    EasyLoading.instance.contentPadding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    );
    EasyLoading.showToast(text, duration: Duration(milliseconds: delay));
  }

  static toastInfo(String text, {int delay = 3000}) {
    EasyLoading.showInfo(text, duration: Duration(milliseconds: delay));
  }

  static loading([String? text]) {
    EasyLoading.instance.contentPadding = const EdgeInsets.symmetric(
      vertical: 12.0,
      horizontal: 20.0,
    );
    EasyLoading.show(status: text);
  }

  static hideLoading() {
    EasyLoading.dismiss();
  }

  static initLoading() {
    EasyLoading.instance
      // ..userInteractions = false
      ..indicatorSize = 36.0
      ..progressColor = Colors.white
      ..backgroundColor = Colors.black
      ..indicatorColor = Colors.white
      ..textColor = Colors.white
      ..maskColor = Colors.black12;
  }

  static md5(String str) {
    return crypto.md5.convert(utf8.encode(str)).toString();
  }

  static String formatTime([int time = 0, String format = 'yy-M-d hh:mm:ss', String locale = 'ko']) {
    initializeDateFormatting('ko');
    var date = DateTime.fromMillisecondsSinceEpoch(time > 0 ? time * 1000 :  DateTime.now().millisecond);
    return DateFormat(format, locale).format(date);
  }

  static timer(dynamic Function() callback, int delay) {
    Timer(Duration(milliseconds: delay), () {
      callback.call();
    });
  }

  static repeatTimer(dynamic Function(Timer timer) callback, int delay, [maxCount = 0]) {
    int count = 0;
    Timer.periodic(Duration(milliseconds: delay), (timer) {
      if (maxCount > 0 && ++count > maxCount) {
        timer.cancel();
      } else {
        callback.call(timer);
      }
    });
  }

  static replacePage(Widget page, {BuildContext? context, bool animation = true}) {
    PageRoute pageRoute;
    if (animation) {
      pageRoute = MaterialPageRoute(builder: (context) => page);
    } else {
      pageRoute = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }
    return Navigator.of(context ?? navigatorKey.currentContext!).pushAndRemoveUntil(pageRoute, (route) => false);
  }

  static pushPage(page, {BuildContext? context, bool animation = false}) {
    PageRoute pageRoute;
    if (animation) {
      pageRoute = MaterialPageRoute(builder: (context) => page);
    } else {
      pageRoute = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }
    return Navigator.of(context ?? navigatorKey.currentContext!).push(pageRoute);
  }

  static popPage([BuildContext? context, dynamic result]) {
    return Navigator.of(context ?? navigatorKey.currentContext!).pop(result);
  }

  static cutString(String str, int length, [suffix = '..']) {
    if (str.length > length) {
      return str.substring(0, length) + '..';
    }
    return str;
  }

  static filter(Map<String, dynamic> data, List<String> keys) {
    if (keys.isEmpty) {
      return data;
    }

    Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (keys.contains(key)) {
        result[key] = value;
      }
    });
    return result;
  }

  static test() {
    toast('테스트');
    // testLoading();
  }

  static testLoading() async {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    } else {
      loading('로딩중입니다...');
    }
  }

  static String _colorize(v) {
    var pattern = RegExp(r'^(#[0-9a-f]{3}|black|red|green|yellow|blue|magenta|cyan|white)[:/]');
    if (!Ansi.enabled) {
      if ((v is String)) {
        v = v.replaceFirst(pattern, '');
        if (RegExp(r'^(\W)\1{2,4}$').hasMatch(v)) {
          v = v * 20;
        }
        return v;
      } else {
        return '$v';
      }
    }

    var result = '';
    var color = '';
    if (v is String) {
      result = v;
      var match = pattern.stringMatch(result);
      if (match != null) {
        result = result.substring(match.length);
        color = match.substring(0, match.length - 1);
      } else if (result.endsWith(' :')) {
        color = '#fd3';
      }
      if (RegExp(r'^(\W)\1{1,4}$').hasMatch(result)) {
        result = result * 20;
      }
    } else {
      result = '$v';
    }

    result = result
        .replaceAllMapped(RegExp(r'(?<=^|\W)(true|false|null)(?=\W|$)'), (match) => Ansi.blue(match[0]!).toString())
        .replaceAllMapped(RegExp(r'(?<=(^|[{, ]))([a-zA-Z]\w+):'), (match) => Ansi.magenta(match[2]!).toString() + ':');

    if (color != '') {
      return Ansi(result, color).toString();
    }
    return result;
  }

  static final debug = DynArgsFunction((arguments) {
    if (kDebugMode) {
      print(Ansi('[ffak] ', '#777').toString() + arguments.map((v) {
        return _colorize(v);
      }).join(' '));
    }
  }) as dynamic;
}

/// Dynamic arguments function
typedef OnCall = dynamic Function(List arguments);
class DynArgsFunction {
  final OnCall _onCall;
  DynArgsFunction(this._onCall);

  @override
  noSuchMethod(Invocation invocation) {
    if (!invocation.isMethod || invocation.namedArguments.isNotEmpty) {
      super.noSuchMethod(invocation);
    }
    final arguments = invocation.positionalArguments;
    return _onCall(arguments);
  }
}
