import 'package:sqflite/sqflite.dart';

class Schema {
  static int version = 1;

  static onCreate(Database db, int version) async {
    // memo
    await db.execute('''
      CREATE TABLE ffak_memo (
        memo_id integer primary key,
        memo_status integer NOT NULL DEFAULT '1',
        memo_password text NOT NULL DEFAULT '',
        memo_content text NOT NULL DEFAULT '',
        memo_ctime integer NOT NULL DEFAULT 0,
        memo_mtime integer NOT NULL DEFAULT 0
      )
    ''');
  }

  static onUpgrade(Database db, int oldVersion, int newVersion) async {
    // nothing yet
  }

  static onDowngrade(Database db, int oldVersion, int newVersion) async {
    // nothing yet
  }
}