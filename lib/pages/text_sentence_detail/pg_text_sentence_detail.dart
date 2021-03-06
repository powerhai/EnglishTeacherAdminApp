import 'package:file_picker/file_picker.dart';
import 'package:finger_manager_app/common/command_icon.dart';
import 'package:finger_manager_app/common/future_change_notifier_provider.dart';
import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oktoast/oktoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

import 'vm_text_sentence.dart';

class PgTextSentenceDetail extends StatefulWidget {
  PgTextSentenceDetail({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PgTextSentenceDetailState();
}

class _PgTextSentenceDetailState extends State<PgTextSentenceDetail> {
  List<PageCommand> commands;
  ProgressDialog pr;

  _PgTextSentenceDetailState() {
    commands = [
      PageCommand(title: "翻译", icon: Icons.translate),
      PageCommand(
        title: "加载音频",
        icon: FingerIcons.music,
      ),
      PageCommand(title: "保存", icon: FingerIcons.save),
    ];
  }

  Widget build2(BuildContext context) {
    SentencesUpdateNavigationArguments ars =
        ModalRoute.of(context).settings.arguments;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    var vm = new VmTextSentence(ars.textId);
    return FutureProvider<VmTextSentence>(
        lazy: false,
        initialData: vm,
        create: (BuildContext context) async {
          await vm.loadData();
          return vm;
        },
        child: Consumer<VmTextSentence>(builder: (context, vm2, cld) {
          return ChangeNotifierProvider<VmTextSentence>.value(
              value: vm2,
              child: Scaffold(
                appBar: buildAppBar(),
                body: buildBody(),
                bottomSheet: buildBottomBar(),
              ));
        }));
  }

  @override
  Widget build(BuildContext context) {
    SentencesUpdateNavigationArguments ars =
        ModalRoute.of(context).settings.arguments;
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    var vm = new VmTextSentence(ars.textId);
    return FutureChangeNotifierProvider<VmTextSentence>(
      lazy: false,
      initialData: vm,
      create: (BuildContext context) async {
        await vm.loadData();
        return vm;
      },
      builder: (BuildContext context, VmTextSentence vm) {
        return Scaffold(
          appBar: buildAppBar(),
          body: buildBody(),
          bottomSheet: buildBottomBar(),
        );
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Sentence",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      primary: true,
      titleSpacing: 0.0,
    );
  }

  Widget buildBody() {
    return Consumer<VmTextSentence>(builder: (context, vm, cld) {
      var col = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: vm.sentences.map((s) => buildRowSentence(s)).toList());
      if (vm.isAudioLoaded) {
        col.children.insert(0, buildPlayBar());
      }
      return col;
    });
  }

  Widget buildRowSentence(Sentence sen) {
    return Consumer<VmTextSentence>(builder: (context, vm, cld) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(width: 0.3, color: Colors.grey[300])),
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Visibility(
                visible: sen.uploadState == UploadState.Uploading,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.blue)),
                )),
            Visibility(
                visible: sen.uploadState == UploadState.Uploaded,
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Icon(Icons.check, color: Colors.green),
                )),
            Visibility(
                visible: sen.uploadState != UploadState.Normal,
                child: SizedBox(
                  height: 10,
                  width: 10,
                )),
            Expanded(
              child: InkWell(
                onTap: () {
                  editSentence(sen, vm);
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
              visible: sen.isAudioExist,
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
    });
  }

  Future<void> pickAudioFile(VmTextSentence vm) async {
    var file = await FilePicker.getFilePath(type: FileType.audio);
    vm.loadAudio(file);
  }

  void editSentence(Sentence sen, VmTextSentence vm) {
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

  Widget buildPlayBar() {
    return Consumer<VmTextSentence>(builder: (context, vm, cld) {
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
    });
  }

  Widget buildBottomBar() {
    return Consumer<VmTextSentence>(builder: (context, vm, cld) {
      return Container(
          color: Colors.grey[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCommandButton(PageCommand(
                  title: "翻译",
                  icon: Icons.translate,
                  command: () => translateSentences(vm))),
              buildCommandButton(PageCommand(
                  title: "加载音频",
                  icon: FingerIcons.music,
                  command: () => pickAudioFile(vm))),
              buildCommandButton(PageCommand(
                  title: "保存", icon: FingerIcons.save, command: () => save(vm)))
            ],
          ));
    });
  }

  Widget buildCommandButton(PageCommand command) {
    return InkWell(
      onTap: command.command,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Icon(command.icon, color: Colors.green),
          Text(command.title, style: TextStyle(color: Colors.green))
        ],
      ),
    );
  }

  Future<void> save(VmTextSentence vm) async {
    // pr.show();
    try {
      await vm.save();
      showToast("保存成功", textPadding: EdgeInsets.all(10));
    } catch (e) {
      showToast(e.toString(), textPadding: EdgeInsets.all(10));
    }
    //  pr.hide();
  }

  void translateSentences(VmTextSentence vm) async {
    pr.show();
    try {
      await vm.translateSentences();
    } catch (e) {
      showToast(e.toString(), textPadding: EdgeInsets.all(10));
    }
    pr.hide();
  }
}
