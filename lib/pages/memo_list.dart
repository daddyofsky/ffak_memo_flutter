import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../library/config.dart';
import '../library/common.dart';
import '../models/memo.dart';
import '../modules/memo.dart';
import '../widgets/search_input.dart';
import 'memo_view.dart';
import 'memo_form.dart';

class MemoListPage extends StatefulWidget {
  const MemoListPage({Key? key}) : super(key: key);

  @override
  State<MemoListPage> createState() => _MemoListPageState();
}

class _MemoListPageState extends State<MemoListPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late MemoModule memoModule = MemoModule();
  late AutoScrollController _listController;

  int currentTopIndex = -1;
  bool isScrolledDown = false;
  bool isPrevListExists = false; //true;
  bool isLoadingPrevList = false;
  bool isSearchOpen = false;

  int? initListCount; // all if null
  String searchText = '';
  String yMd = Common.formatTime(0, 'y.M.d');

  @override
  initState() {
    super.initState();
    _listController = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
      // initialScrollOffset: 1000000
    );
    _listController.addListener(_scrollListener);

    getMemoList();
  }

  @override
  void dispose() {
    _listController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    yMd = Common.formatTime(0, 'y.M.d');
    super.didUpdateWidget(oldWidget);
  }

  void _scrollListener() {
    if (!isLoadingPrevList&& isPrevListExists
        && _listController.offset > _listController.position.maxScrollExtent - 200 ) {
      debug('getPrevMemoList');
      getPrevMemoList();
    }

    var isDown = _listController.offset > 100;
    if (!isScrolledDown && isDown) {
      setState(() {
        isScrolledDown = true;
        debug('DOWN');
      });
    } else if (isScrolledDown && !isDown) {
      setState(() {
        isScrolledDown = false;
        debug('TOP');
      });
    }
  }

  enterMemoView(memo) async {
    debug('blue:>>>>>', 'MemoList', '--->', 'red:MemoView', memo.memoId);
    Common.pushPage(MemoViewPage(memo: memo, onModify: modifyMemo, onDelete: deleteMemo,), context: context).then((memo) {
      // TODO
      debug('blue:<<<<<', 'MemoList', '<---', 'red:MemoView', memo);

    });
  }

  enterMemoForm() async {
    debug('blue:>>>>>', 'MemoList', '--->', 'red:MemoForm');
    Common.pushPage(MemoFormPage(), context: context).then((memoContent) {
      debug('blue:<<<<<', 'MemoList', '<---', 'red:MemoForm', memoContent);
      if (memoContent != null) {
        addMemo(memoContent);
      }
    });
  }

  getMemoList() async {
    await memoModule.getMemoList(initListCount);
    setState(() {});
  }

  getPrevMemoList() async {
    isLoadingPrevList = true;
    var count = 10;
    var resultCount = await memoModule.getPrevMemoList(count);
    if (resultCount > 0) {
      setState(() {
        isLoadingPrevList = false;
      });
    } else {
      isLoadingPrevList = false;
    }
    if (resultCount < count) {
      isPrevListExists = false;
    }
  }

  addMemo(String message) async {
    memoModule.addMemo(message).then((_) {
      setState(() {});
    });
  }

  Future<void> modifyMemo(MemoItem memo, [int? index]) async {
    memoModule.modifyMemo(memo, index).then((_) {
      setState(() {});
    });
  }

  Future<void> deleteMemo(MemoItem memo, [int? index]) async {
    memoModule.deleteMemo(memo, index).then((_) {
      setState(() {});
    });
  }

  jumpTo(offset, {animate = true}) {
    if (animate) {
      _listController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _listController.jumpTo(offset);
    }
  }

  jumpToIndex(int index) {
    debug('jumpToIndex : $index');
    _listController.scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
  }

  jumpToTop() {
    Common.timer(() {
      var offset = _listController.position.maxScrollExtent;
      // var offset = 0;
      jumpTo(offset);
    }, 100);
  }

  jumpToBottom() {
    Common.timer(() {
      // var offset = _listController.position.maxScrollExtent;
      var offset = 0.0;
      jumpTo(offset);
    }, 100);
  }

  formatTime(time) {
    var date = Common.formatTime(time, 'yy.MM.dd');
    if (date != Common.formatTime(DateTime.now().millisecondsSinceEpoch ~/ 1000, 'yy.MM.dd')) {
      return date;
    }
    return Common.formatTime(time, 'jm');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: const Text(Config.brandName),
        centerTitle: true,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(onPressed: () {
            setState(() {
              isSearchOpen = !isSearchOpen;
            });
          }, icon: const Icon(Icons.search))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Visibility(visible: isSearchOpen,child: buildSearch()),
            Expanded(
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: ListView.builder(
                    controller: _listController,
                    itemCount: memoModule.memoList.length,
                    itemBuilder: (context, index) {
                      return buildMemoItem(memoModule.memoList[index], index);
                    }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: FloatingActionButton(
            onPressed: () {
              enterMemoForm();
            },
            backgroundColor: Theme.of(context).primaryColor, //Colors.blue,
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildMemoItem(MemoItem item, int index) {
    return Visibility(
      visible: searchText.isEmpty || item.memoContent.contains(searchText),
      child: Card(
        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: ListTile(
          onTap: () {
            // view memo
            if (item.memoPassword.isNotEmpty) {
              Common.confirmPassword('비밀번호를 입력해주십시오.', context: context).then((password) {
                if (password == null || password.isEmpty || Common.md5(password) != item.memoPassword) {
                  Common.toast('비밀번호가 맞지 않습니다.');
                  return;
                }
                enterMemoView(item);
              });
            } else {
              enterMemoView(item);
            }
          },
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              item.memoPassword.isNotEmpty ? '비밀메모 입니다' : item.memoContent,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  height: 2.0,
                  color: item.memoPassword.isNotEmpty ? Colors.black54 : Colors.black87),
            ),
          ),
          trailing: SizedBox(
            width: 60,
            child: Row(
              children: [
                Container(
                      width: 60,
                      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                      child: Column(
                        children: [
                          Text(formatTime(item.memoTime),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          item.memoPassword.isNotEmpty ? const Icon(CupertinoIcons.lock) : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                // const Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearch() {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: SearchInput(
        text: searchText,
        onSubmit: (text) {
          setState(() {
            searchText = text;
            if (text.isEmpty) {
              isSearchOpen = false;
            }
          });
        },
      ),
    );
  }
}