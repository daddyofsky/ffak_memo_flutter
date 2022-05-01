import '../library/common.dart';
import '../models/memo.dart';

class MemoModule {
  List<MemoItem> memoList = [];
  late MemoDB db = MemoDB();

  int memoLength = 0;
  late String today = Common.formatTime(0, 'yMMMMEEEEd');

  Future<int> getMemoList(int count) async {
    await db.open();
    var data = await db.findAll(1, '*', 'memo_id DESC', count).catchError((e) {
      Common.error('메모목록 가져오기 오류 : $e');
      throw e;
    });

    debug('getMemoList', data);

    if (data.isNotEmpty) {
      try {
        return procPartMemoList(data);
      } catch (e, trace) {
        debug(trace);
        Common.error('메모목록 표시 오류 : $e');
      }
    }

    return 0;
  }

  Future<int> getPrevMemoList(int count) async {
    var lastIndex = memoLength - 1;
    var maxMemoId = memoList[lastIndex].memoId;

    debug('getPrevMemoList :', 'maxMemoId =', maxMemoId);
    var data = await db.findAll(['memo_id < ?', maxMemoId], '*', 'memo_id DESC', count).catchError((e) {
      Common.error('이전 메모목록 가져오기 오류 : $e');
      throw e;
    });

    if (data.isNotEmpty) {
      debug('count :', data.length);
      try {
        return procPartMemoList(data);
      } catch (e, trace) {
        debug(trace);
        Common.error('이전 메모목록 표시 오류 : $e');
      }
    }
    return 0;
  }

  int procPartMemoList(data) {
    var _partMemoList = <MemoItem>[];
    try {
      for (var v in data) {
        _partMemoList.add(MemoItem(v));
      }
      int length = _partMemoList.length;
      debug('count :', length);
      memoList.addAll(_partMemoList);
      memoLength += length;
      return length;
    } catch (e, trace) {
      debug(trace);
      Common.error('메모목록 처리 오류 : $e');
    }
    return 0;
  }

  addMemo(String memoContent) async {
    if (memoContent == '') {
      return;
    }

    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var memo = {
      'memo_status': 0,
      'memo_content': memoContent,
      'memo_ctime': now,
      'memo_mtime': now,
    };

    debug('addMemo :', memo);

    var id = await db.insert(memo);
    debug('addMemo :', id);
    memo['memo_id'] = id;
    memoList.insert(0, MemoItem(memo));
  }

  modifyMemo(MemoItem memo, [int? index]) async {
    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var data = {
      'memo_content': memo.memoContent,
      'memo_mtime': now,
    };
    await db.update(data, ['memo_id = ?', memo.memoId]);

    index ??= memoList.indexWhere((element) => element.memoId == memo.memoId);
    debug('modifyMemo :', memo.memoId, index);
    if (index >= 0) {
      memoList[index].memoContent = memo.memoContent;
      memoList[index].memoTime = now;
    }
  }

  deleteMemo(MemoItem memo, [int? index]) async {
    await db.delete(['memo_id = ?', memo.memoId]);

    index ??= memoList.indexWhere((element) => element.memoId == memo.memoId);
    debug('deleteMemo :', memo.memoId, index);
    if (index >= 0) {
      memoList.removeAt(index);
    }
  }
}