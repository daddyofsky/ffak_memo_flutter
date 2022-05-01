import '../library/config.dart';
import '../library/db.dart';

class MemoItem {
  int memoId = 0;
  int memoStatus = 0;
  String memoContent = '';
  int memoCreateTime = 0;
  int memoTime = 0;

  MemoItem([Map<String, dynamic>? data]) {
    if (data != null) {
      fromMap(data);
    }
  }

  fromMap(Map<String, dynamic> data) {
    memoId = int.parse((data['memo_id'] ?? 0).toString());
    memoStatus = int.parse((data['memo_status'] ?? 0).toString());
    memoContent = (data['memo_content'] ?? '').toString();
    memoCreateTime = int.parse((data['memo_ctime'] ?? 0).toString());
    memoTime = int.parse((data['memo_mtime'] ?? 0).toString());
  }

  toMap() {
    return {
      'memo_id' : memoId,
      'memo_status' : memoStatus,
      'memo_content' : memoContent,
      'memo_ctime' : memoCreateTime,
      'memo_mtime' : memoTime,
    };
  }
}

class MemoDB extends DB {
  @override
  List<String> get keys => [
    'memo_id',
    'memo_status',
    'memo_content',
    'memo_ctime',
    'memo_mtime',
  ];

  MemoDB() : super(Config.dbName) {
    setTable('ffak_memo', 'memo_id');
  }
}