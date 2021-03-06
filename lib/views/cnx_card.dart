import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CnxCard extends StatelessWidget {
  final Widget leading;
  final String header;
  final Widget headerButton;
  final Widget body;

  const CnxCard(
      {Key key, this.leading, this.header, this.headerButton, this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 0.3, color: Colors.grey[400])),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                padding: EdgeInsets.all(12),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    leading,
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      this.header,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                    SizedBox(width: 10),
                    headerButton
                  ],
                )),
            Divider(height: 0.3, color: Colors.grey[300]),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),
                  ),
                  padding: EdgeInsets.all(5),
                  child: this.body),
            ),
          ])),
    );
  }
}
