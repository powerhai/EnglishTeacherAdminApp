import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/domain/pages.dart';
import 'package:finger_manager_app/pages/text_sentence_detail/vm_text_sentence.dart';
import 'package:finger_manager_app/views/cnx_card.dart';
import 'package:finger_manager_app/views/cnx_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'v_article_source.dart';
import 'v_rich_text.dart';
import 'v_sentence.dart';
import 'vm_article.dart';
import 'vm_text_body.dart';
import 'vm_text_format.dart';

class PgArticle extends StatefulWidget {
  PgArticle({Key key}) : super(key: key);

  @override
  _PgArticleState createState() => _PgArticleState();
}

class _PgArticleState extends State<PgArticle> {
  BuildContext context;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> onBackPressed() async {
    return true;
  }

  TextEditingController controllerBody = new TextEditingController();
  TextEditingController controllerTitle = new TextEditingController();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    this.context = context;
    TextNavigationArguments ars = ModalRoute.of(context).settings.arguments;

    VmTextBody vm =
        new VmTextBody(ars.bookId, ars.operationType, textId: ars.textId);
    return FutureProvider<VmTextBody>(
        lazy: false,
        initialData: vm,
        create: (BuildContext ctx) async {
          await vm.initTextBody();
          controllerTitle.text = vm.textTitle;
          controllerBody.text = vm.textBody;
          return vm;
        },
        child: ChangeNotifierProvider<VmTextBody>.value(
            value: vm,
            child: WillPopScope(
              onWillPop: onBackPressed,
              child: Scaffold(
                appBar: buildAppBar(),
                body: buildBody(),
                bottomSheet: buildBottomBar(),
              ),
            )));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Text",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      primary: true,
      titleSpacing: 0.0,
    );
  }

  Widget buildBody() {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: FormBuilder(
            key: _fbKey,
            initialValue: {
              'title': "",
            },
            autovalidate: true,
            child: Consumer<VmTextBody>(
              builder: (BuildContext context, vm, Widget child) {
                if (vm?.isLoaded != true) return Text("Loading...");

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      buildGroupText(vm),
                      buildGroupSentence(vm)
                    ],
                  ),
                );
              },
            )));
  }

  Widget buildRowArticleTitle(VmTextBody vm) {
    return FormBuilderTextField(
      onChanged: (value) {
        vm.textTitle = value;
      },
      controller: controllerTitle,
      maxLength: 50,
      attribute: "title",
      decoration: InputDecoration(
          isDense: true,
          icon: Icon(Icons.title),
          labelText: "Title",
          floatingLabelBehavior: FloatingLabelBehavior.auto),
      validators: [
        FormBuilderValidators.required(),
      ],
    );
  }

  Widget buildRowArticleBody(VmTextBody vm) {
    return FormBuilderTextField(
      //initialValue: vm.textBody,
      controller: controllerBody,
      onChanged: (value) {
        vm.textBody = value;
      },
      maxLines: null,
      attribute: "body",
      decoration: InputDecoration(
          isDense: true,
          icon: Icon(Icons.title),
          labelText: "Body",
          floatingLabelBehavior: FloatingLabelBehavior.auto),
      validators: [
        FormBuilderValidators.required(),
      ],
    );
  }

  Widget buildCommandButton(IconData icon, String title, Function command) {
    return InkWell(
      onTap: command,
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.green),
          Text(title, style: TextStyle(color: Colors.green))
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    return Consumer<VmTextBody>(
      builder: (BuildContext context, vm, Widget child) {
        return Container(
            color: Colors.grey[300],
            padding: EdgeInsets.all(3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildCommandButton(Icons.text_format, "Format", () {
                  format(vm);
                }),
                buildCommandButton(Icons.text_format, "Discover", () {
                  collectSentences(vm);
                }),
                buildCommandButton(FingerIcons.save, "Save", () {
                  save(vm);
                }),
              ],
            ));
      },
    );
  }

  Widget buildGroupText(VmTextBody vm) {
    return CnxCard(
        leading: Icon(FingerIcons.book, size: 16, color: Colors.grey),
        header: "Text",
        headerButton: SizedBox(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildRowArticleTitle(vm),
            buildRowArticleBody(vm),
            ViewRichText(),
          ],
        ));
  }

  Widget buildGroupSentence(VmTextBody vm) {
    var col = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[]);
    vm.sentences.forEach((sen) {
      col.children.add(ListTile(
          isThreeLine: false,
          dense: true,
          title: Text(sen.english,
              style: TextStyle(
                  color: sen.chinese == "" ? Colors.red : Colors.green)),
          subtitle: Text(sen.chinese)));
    });
    return CnxCard(
        headerButton: Material(
          color: Colors.transparent,
          child: Container(
            height: 30,
            child: IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(FingerIcons.edit, color: Colors.lightGreen),
              onPressed: () {
                Navigator.pushNamed(context, RoutePages.textSentenceDetail,
                    arguments:
                        new SentencesUpdateNavigationArguments(vm.textId));
              },
            ),
          ),
        ),
        leading: Icon(FingerIcons.book, size: 16, color: Colors.grey),
        header: "Sentences",
        body: col);
  }

  void format(VmTextBody vm) {
    vm.formatArticleBody();
    showToast("课文格式化完成", textPadding: EdgeInsets.all(10));
    controllerBody.text = vm.textBody;
  }

  void collectSentences(VmTextBody vm) {
    vm.collectSentences();
    showToast("句子采集完成", textPadding: EdgeInsets.all(10));
  }

  void save(VmTextBody vm) {
    //String title = controllerTitle.text;
    //String body = controllerBody.text;
    vm.save();
    showToast("课文保存成功", textPadding: EdgeInsets.all(10));
  }
}
