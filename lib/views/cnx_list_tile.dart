import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CnxListTile extends StatelessWidget {
  final Widget title;
  final Widget trailing;
  final Widget leading;
  final double height;
  final Color backgroundColor;
  final bool showBottomLine;
  const CnxListTile(
      {Key key,
      this.title,
      this.trailing,
      this.leading = const SizedBox(),
      this.height = 40,
      this.backgroundColor = Colors.white,
      this.showBottomLine = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: DefaultTextStyle(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0 , horizontal:10.0),
              child: title,
            ),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );

    if (leading != null) row.children.insert(0, leading);
    if (trailing != null) row.children.add(trailing);

    return Container(
        height: this.height,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          color: this.backgroundColor,
          border: Border(
              bottom: BorderSide(
                  width: 0.3,
                  color: this.showBottomLine
                      ? Colors.grey[300]
                      : this.backgroundColor)),
        ),
        child: row);
  }
}
