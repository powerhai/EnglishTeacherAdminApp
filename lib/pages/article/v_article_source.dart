import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/pages/article/v_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'vm_text_body.dart';

class ViewArticleInfo extends StatefulWidget {
  ViewArticleInfo({Key key}) : super(key: key) {}

  @override
  State<StatefulWidget> createState() => _ViewArticleInfoState();
}

class _ViewArticleInfoState extends State<ViewArticleInfo> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(5.0),
          child: FormBuilder(
              key: _fbKey,
              initialValue: {
                'title': "",
              },
              autovalidate: true,
              child:
                  Consumer<VmTextBody>(
                    builder: (BuildContext context, vm, Widget child) {
                      if (vm?.isLoaded != true) return Text("Loading...");

                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[ 
                            ViewRichText(),
                            Text(vm.textTitle)
                          ],
                        ),
                      );
                    },
                  ))),
     
    );
  }





}
