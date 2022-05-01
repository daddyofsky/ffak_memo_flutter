import 'package:flutter/material.dart';
import 'package:scroll_to_index/util.dart';

import '../library/common.dart';
import '../models/memo.dart';

class MemoFormPage extends StatefulWidget {
  MemoFormPage({this.memo, Key? key}) : super(key: key);

  MemoItem? memo;

  @override
  State<MemoFormPage> createState() => _MemoFormPageState();
}

class _MemoFormPageState extends State<MemoFormPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final _talkContentController = TextEditingController();
  bool isEmptyTalkContent = true;

  @override
  initState() {
    super.initState();

    debug(widget.memo?.toMap());
    _talkContentController.text = widget.memo?.memoContent ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(widget.memo != null ? '메모 수정' : '메모 등록'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black38),
                ),
                child: TextField(
                  controller: _talkContentController,
                  keyboardType: TextInputType.multiline,
                  decoration: null,
                  maxLines: null,
                ),
              ),
            ),
            SizedBox(
                child: ElevatedButton.icon(
                  onPressed: () {
                    var memoContent = _talkContentController.text.trim();
                    debug(memoContent);
                    Common.popPage(context, memoContent);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('등록'),
                ),
             )
          ]),
        ),
      ),
    );
  }
}