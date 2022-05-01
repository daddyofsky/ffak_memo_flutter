import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchInput extends StatefulWidget {
  final void Function(String message) onSubmit;
  String text;

  SearchInput({required this.onSubmit, this.text = '', Key? key}) : super(key: key);

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final _searchContentController = TextEditingController();
  bool isEmptySearchContent = true;

  @override
  initState() {
    super.initState();
    _searchContentController.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          Expanded(
            child: RawKeyboardListener(
              focusNode: FocusNode(onKey: (FocusNode node, RawKeyEvent event) {
                if ([LogicalKeyboardKey.enter, LogicalKeyboardKey.numpadEnter]
                    .contains(event.logicalKey) &&
                    !(event.isControlPressed ||
                        event.isShiftPressed ||
                        event.isMetaPressed)) {
                  if (event is RawKeyDownEvent) {
                    widget.onSubmit(_searchContentController.text.trim());
                    return KeyEventResult.handled;
                  }
                }

                if (event is RawKeyUpEvent && isEmptySearchContent != _searchContentController.text.isEmpty) {
                  setState(() {
                    isEmptySearchContent = _searchContentController.text.isEmpty;
                  });
                }
                return KeyEventResult.ignored;
              }),
              child: TextField(
                controller: _searchContentController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration.collapsed(hintText: '검색어를 입력하세요.'),
                maxLines: 1,
              ),
            ),
          ),
          Visibility(
            visible: _searchContentController.text.isNotEmpty,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    widget.onSubmit('');
                    _searchContentController.text = '';
                    isEmptySearchContent = true;
                  });
                },
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 14, color: Colors.white,),
              ),
            ),
          )
        ]),
      ),
    );
  }
}