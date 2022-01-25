
import 'package:flutter/material.dart';

class TextDropdown extends StatefulWidget {
  final String text;
  final int toSplit;
  final TextStyle? style;
  const TextDropdown(
      {Key? key, required this.text, required this.toSplit, this.style})
      : super(key: key);
  @override
  _TextDropdownState createState() => _TextDropdownState();
}

class _TextDropdownState extends State<TextDropdown> {
  String get text => widget.text;
  int get toSplit => widget.toSplit;
  String get first =>
      text.substring(0, toSplit < text.length ? toSplit : text.length) +
      (toSplit < text.length ? ' ...' : ' .');
  bool flag = true;
  double marg = 10;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (toSplit < text.length) {
          setState(
            () {
              flag = !flag;
            },
          );
        }
      },
      child: Column(
        children: [
          SizedBox(
            height: marg,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Summary",
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 17,
                      letterSpacing: 1,
                    ),
              ),
              Icon(
                flag ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              )
            ],
          ),
          SizedBox(
            height: marg,
          ),
          Text(
            flag ? first : text,
            style: widget.style,
          ),
        ],
      ),
    );
  }
}
