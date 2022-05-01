import 'package:flutter/material.dart';

import '../library/common.dart';
import '../models/memo.dart';
import 'memo_form.dart';

typedef ModifyMemo = Future<void> Function(MemoItem, [int?]);
typedef DeleteMemo = Future<void> Function(MemoItem, [int?]);

class MemoViewPage extends StatefulWidget {
  MemoViewPage({required this.memo, required this.onModify, required this.onDelete, Key? key}) : super(key: key);

  MemoItem memo;
  final ModifyMemo onModify;
  final DeleteMemo onDelete;

  @override
  State<MemoViewPage> createState() => _MemoViewPageState();
}

class _MemoViewPageState extends State<MemoViewPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  enterMemoForm() async {
    debug('blue:>>>>>', 'MemoView', '--->', 'red:MemoForm');
    Common.pushPage(MemoFormPage(memo: widget.memo), context: context).then((memo) {
      debug('blue:<<<<<', 'MemoView', '<---', 'red:MemoForm', memo);
      // TODO
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text('메모 보기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.memo.memoContent,
                    style: const TextStyle(
                      fontSize: 16
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, //MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Common.pushPage(MemoFormPage(memo: widget.memo), context: context).then((memoContent) {
                      if (memoContent != null) {
                        setState(() {
                          widget.memo.memoContent = memoContent;
                          widget.onModify(widget.memo);
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Common.confirm('삭제하시겠습니까?', context: context).then((r) {
                      debug('confirm', r);
                      if (r) {
                        widget.onDelete(widget.memo);
                        Common.popPage(context);
                      }
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('삭제'),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }
}