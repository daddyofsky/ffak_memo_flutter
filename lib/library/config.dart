import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../library/common.dart';

class Config {
  // app
  static const brandName = '빡메모';
  static const name = 'ffak_memo';
  static const version = '1.0.0';
  static bool get debug {
    return kDebugMode;
  }
  static String get dbName {
    return debug ? 'ffak_memo-dev.db' : 'ffak_memo.db';
  }
  static const key = 'f0e37c4072350555da17117069ae8bc0'; // 32 length

  // env
  static late String appDirectory;
  static bool get isDesktop {
    if (kIsWeb) return false;
    return [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);
  }
  static bool isWindows = defaultTargetPlatform == TargetPlatform.windows;
  static bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;

  // state
  static bool isActive = true;
  static String currentPage = '';
  static late dynamic currentWidget;

  // storage data
  static late final GetStorage _storage;
  static late Future<bool> ready = Future<bool>(() async {

    Common.debug('>>', 'CONFIG READY', '<<');

    appDirectory = (await getApplicationSupportDirectory()).path;
    Common.debug('Document Directory :', appDirectory);

    var container = debug ? 'ffak_memo-dev' : 'ffak_memo';
    _storage = GetStorage(container, appDirectory);
    await GetStorage.init(container);

    return true;
  });

  static dynamic get(String key, [defaultValue]) {
    var value = _storage.read(key);
    if (value == null && defaultValue != null) {
      value = defaultValue;
      _storage.write(key, defaultValue);
    }
    return value;
  }

  static set(String key, value) {
    Common.debug('Config.set :', '$key = $value');
    _storage.write(key, value);
    return value;
  }

  static Future<void> remove(String key) {
    return _storage.remove(key);
  }
}