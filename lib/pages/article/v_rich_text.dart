import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'vm_article.dart';
import 'vm_text_body.dart';
import 'vm_text_format.dart';

class ViewRichText extends StatefulWidget {
  const ViewRichText({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewRichTextState();
}

class _ViewRichTextState extends State<ViewRichText> {
  @override
  Widget build(BuildContext context) {
    var vm = Provider.of<VmTextBody>(context, listen: true);
    var rootSpan = TextSpan(children: []);
    var start = 0;
    for (var i = 0; i < vm.sentences.length; i++) {
      var sen = vm.sentences[i];
      var index = vm.textBody.indexOf(sen.english, start);
      if (index > start) {
        var otherText = vm.textBody.substring(start, index);
        rootSpan.children.add(TextSpan(
            text: otherText, style: TextStyle(color: Colors.grey[700])));
      }
      start = index + sen.english.length;

      rootSpan.children.add(TextSpan(
          text: (i + 1).toString(),
          style: TextStyle(
              color: Colors.white,
              backgroundColor: Colors.orange,
              wordSpacing: 30)));
      rootSpan.children.add(TextSpan(
          text: sen.english,
          style: TextStyle(
            color: Colors.blue,
          )));
    }
    return Consumer<VmTextBody>(
        builder: (BuildContext context, vm, Widget child) {
      return Container(
        decoration: BoxDecoration(color: Colors.grey[100] ),
        padding: EdgeInsets.all(10.0),
        child: RichText(text: rootSpan),
      );
    });
  }
}
