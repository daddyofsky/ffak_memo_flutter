import 'package:sqflite/sqflite.dart';
import '../models/schema.dart';
import '../library/common.dart';

class DB {
  static Map<String, Database?> dbList = {};
  static bool connected = false;

  String dbName;
  bool get isOpen => (connected ? db.isOpen : false);
  Database get db {
    return dbList[dbName]!;
  }

  String table = '';
  String primaryKey = '';
  List<String> keys = [];

  DB(this.dbName);

  open() async {
    if (dbList[dbName] == null || !dbList[dbName]!.isOpen) {
      // await Sqflite.setDebugModeOn(true);
      var path = await getDatabasesPath() + '/' + dbName;
      debug('db open :', path);
      dbList[dbName] = await openDatabase(path,
          version: Schema.version,
          onCreate: Schema.onCreate,
          onUpgrade: Schema.onUpgrade,
          onDowngrade: Schema.onDowngrade,
      );
    }
    return this;
  }

  Future<void> close() async {
    return db.close().then((r) {
      dbList[dbName] = null;
      return r;
    });
  }

  setTable(String table, String primaryKey) {
    this.table = table;
    this.primaryKey = primaryKey;
  }

  Future<Map<String, Object?>> get(id, [String column = '*']) {
    return db.query(table, columns: [column], where: '$primaryKey = ?', whereArgs: [id], limit: 1).then((r) {
      return r.isNotEmpty ? r[0] : {};
    });
  }

  Future<int> set(Map<String, Object?> values, id) {
    if (id == null || id.toString().isEmpty) {
      // Empty where is not allowed for update
      // prevent accident update all rows
      return Future.value(0);
    }
    return db.update(table, values, where: '$primaryKey = ?', whereArgs: [id]);
  }

  Future<int> findCount(where, [String column = '*', String? group]) {
    var _where = _parseWhere(where);
    return db.query(table, columns: ["COUNT($column) AS count"], where: _where['where'], whereArgs: _where['whereArg'], groupBy: group, limit: 1).then((r) {
      return r.isNotEmpty ? int.parse((r[0]['count'] ?? 0).toString()) : 0;
    });
  }

  Future<dynamic> findColumn(where, String column, [String? order]) {
    var _where = _parseWhere(where);
    return db.query(table, columns: [column], where: _where['where'], whereArgs: _where['whereArg'], orderBy: order, limit: 1).then((r) {
      return r.isNotEmpty ? r[0].values.first : null;
    });
  }

  Future<Map<String, Object?>> find(where, [String column = '*', String? order, String? group]) {
    var _where = _parseWhere(where);
    return db.query(table, columns: [column], where: _where['where'], whereArgs: _where['whereArg'], groupBy: group, orderBy: order, limit: 1).then((r) {
      return r.isNotEmpty ? r[0] : {};
    });
  }

  Future<List<Map<String, Object?>>> findAll(where, [String column = '*', String? order, int? limit, int? offset, String? group]) {
    var _where = _parseWhere(where);
    return db.query(table, columns: [column], where: _where['where'], whereArgs: _where['whereArg'], groupBy: group, orderBy: order, limit: limit, offset: offset);
  }

  Future<int> insert(Map<String, Object?> values, [bool update = false]) {
    var data = filter(values, keys);
    if (data.isEmpty) {
      return Future.value(0);
    }

    ConflictAlgorithm conflictAlgorithm= update == true ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore;
    return db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(Map<String, Object?> values, where) {
    var _where = _parseWhere(where);
    if (_where['where'] == null) {
      // Empty where is not allowed for update
      // prevent accident update all rows
      return Future.value(0);
    }

    var data = filter(values, keys);
    if (data.isEmpty) {
      return Future.value(0);
    }

    return db.update(table, values, where: _where['where'], whereArgs: _where['whereArg']);
  }

  Future<int> delete(where) {
    var _where = _parseWhere(where);
    if (_where['where'] == null) {
      // Empty where is not allowed for delete
      // prevent accident delete all rows
      return Future.value(0);
    }
    return db.delete(table, where: _where['where'], whereArgs: _where['whereArg']);
  }

  Future<List<Map<String, Object?>>> query({String? table, bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) {
    return db.query(table ?? this.table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) {
    return db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    return db.rawInsert(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    return db.rawUpdate(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    return db.rawDelete(sql, arguments);
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) {
    return db.execute(sql, arguments);
  }

  Future<int> getVersion() {
    return db.getVersion();
  }

  Future<void> setVersion(int version) {
    return db.setVersion(version);
  }

  Batch batch() {
    return db.batch();
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action, {bool? exclusive}) {
    return db.transaction(action, exclusive: exclusive);
  }

  Map<String, dynamic> filter(Map<String, dynamic> data, List<String> keys) {
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

  Map<String, dynamic> _parseWhere(where) {
    List<Object?>? _whereArg;
    String? _where;
    if (where is List) {
      _where = where.isNotEmpty ? where[0] : null;
      _whereArg = where.sublist(1);
    } else {
      _where = where?.toString();
    }

    if (_where != null && _where.isEmpty) {
      _where = null;
    }

    return { 'where': _where, 'whereArg': _whereArg };
  }
}