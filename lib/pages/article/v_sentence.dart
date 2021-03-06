import 'package:file_picker/file_picker.dart';
import 'package:finger_manager_app/common/command_icon.dart';
import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktoast/oktoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'vm_article.dart';
import '../text_sentence_detail/vm_text_sentence.dart';

class ViewSentence extends StatefulWidget {
  ViewSentence({Key key}) : super(key: key);

  @override
  _ViewSentenceState createState() => _ViewSentenceState();
}

class _ViewSentenceState extends State<ViewSentence>
    with WidgetsBindingObserver {
  VmTextSentence vm;
  List<PageCommand> commands;
  ProgressDialog pr;

_ViewSentenceState(){
  commands = [
    PageCommand(title: "翻译", icon: Icons.translate, command: translateSentences),
    PageCommand(title: "加载音频", icon: FingerIcons.music, command: pickAudioFile),
    PageCommand(title: "保存", icon: FingerIcons.save),
  ];
}
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<VmTextSentence>(context);

    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    return Scaffold(
      body: buildBody(),
      bottomSheet: buildBottomBar(),
    );
  }

  Widget buildBody() {
    var col = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: vm.sentences.map((s) => buildRowSentence(s)).toList());
    if (vm.isAudioLoaded) {
      col.children.insert(0, buildPlayBar());
    }
    return col;
  }

  Widget buildRowSentence(Sentence sen) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(width: 0.3, color: Colors.grey[300])),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                editSentence(sen);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(sen.english),
                  Text(sen.chinese, style: TextStyle(color: Colors.blue)),
                  Visibility(
                    visible: vm.isAudioLoaded,
                    maintainSize: false,
                    child: Container(
                      height: 20,
                      child: RangeSlider(
                          labels: RangeLabels(sen.startAudio.toString(),
                              sen.endAudio.toString()),
                          min: 0,
                          max: vm.duration.toDouble(),
                          onChanged: (RangeValues value) {
                            vm.updateSentenceAudioRange(
                                sen, value.start, value.end);
                          },
                          values: RangeValues(sen.startAudio, sen.endAudio)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: vm.isAudioLoaded,
            maintainSize: false,
            child: Container(
              width: 25,
              child: IconButton(
                  color: Colors.grey[600],
                  icon: Icon(FingerIcons.play),
                  onPressed: () {
                    vm.playSentenceAudio(sen);
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget buildPlayBar() {
    return Container(
      color: Colors.grey[200],
      child: Row(
        children: <Widget>[
          Expanded(
            child: Slider(
              label: vm.position.toString(),
              onChangeStart: (value) {
                vm.pause();
                print("onChangeStart ${value}");
              },
              onChangeEnd: (value) {
                print("onChangeEnd  ${value}");
                vm.resume();
              },
              onChanged: (value) {
                print("onChanged  ${value}");
                vm.moveTo(value.toInt());
              },
              min: 0.0,
              max: vm.duration.toDouble(),
              value: vm.position.toDouble(),
              activeColor: Colors.blue,
            ),
          ),
          vm.isPlaying
              ? IconButton(
                  color: Colors.grey[600],
                  icon: Icon(FingerIcons.pause),
                  onPressed: () {
                    vm.pause();
                  },
                )
              : IconButton(
                  color: Colors.grey[600],
                  icon: Icon(FingerIcons.play),
                  onPressed: () {
                    vm.resume();
                  },
                )
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
        color: Colors.grey[300],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:  commands.map((e) => this.buildCommandButton(e)).toList() ,
        ));
  }

Widget buildCommandButton(PageCommand command) {
    return InkWell(
      onTap: command.command,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        crossAxisAlignment:  WrapCrossAlignment.center,
        children: <Widget>[
          Icon(command.icon, color: Colors.green),
          Text(command.title, style: TextStyle(color: Colors.green))
        ],
      ),
    );
  }

  

  Future<void> pickAudioFile() async {
    var file = await FilePicker.getFilePath(type: FileType.audio);
    vm.loadAudio(file);
  }

  void editSentence(Sentence sen) {
    TextEditingController controller =
        new TextEditingController(text: sen.chinese);

    FocusNode focusNode = new FocusNode();
    showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            insetPadding: EdgeInsets.all(1),
            title: new Text("Update chinese"),
            content: new TextField(
              focusNode: focusNode,
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide(width: 0.3)),
                labelText: '汉语解释',
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("取消"),
              ),
              new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  vm.updateSentenceChinese(sen, controller.text);
                },
                child: new Text("确认"),
              ),
            ],
          );
        });
  }

  translateSentences() async {
    pr.show();
    try {
        await vm.translateSentences();      
    } catch (e) {
      showToast(e.toString(), textPadding: EdgeInsets.all(10));
    }
    pr.hide();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
