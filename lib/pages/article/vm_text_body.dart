import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:finger_manager_app/services/sentence_service.dart';
import 'package:finger_manager_app/services/text_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmTextBody extends ChangeNotifier {
  TextService _textService;
  SentenceService _sentenceService;
  VmTextBody(this.bookId, this.operationType, {this.textId}) {
    _textService = GetIt.instance.get<TextService>();
    _sentenceService = GetIt.instance.get<SentenceService>();
  }
  int bookId;
  int textId;
  bool isLoaded = false;
  String _textBody = "";
  String _textTitle = "";
  List<Sentence> sentences = [];
  List<Sentence> oldSentences = [];

  NavigationOperationType operationType;

  String get textBody => _textBody;
  set textBody(String vale) {
    this._textBody = vale;
    //this.notifyListeners();
  }

  String get textTitle => _textTitle;
  set textTitle(String vale) {
    this._textTitle = vale;
    this.notifyListeners();
  }

  void formatArticleBody() {
    //去除多余空格
    var text =
        _textBody.replaceAll(new RegExp(r"[ \t]{2,}", multiLine: true), " ");
    //去除空行
    text = text.replaceAll(RegExp("\n\n"), "\n");
    textBody = text;
  }

  Future initTextBody() async {
    if (operationType == NavigationOperationType.Add) {
      isLoaded = true;
      return;
    }
    var rv = await _textService.getText(this.textId);
    this.textBody = rv.body;
    this.textTitle = rv.title;
    var sens = await _sentenceService.getSentencesOfText(textId);
    this.sentences.addAll(sens);
    this.oldSentences.addAll(sens);
    isLoaded = true;
    this.notifyListeners();
  }

  Future save() async {
    collectSentences();
    if (operationType == NavigationOperationType.Add) {
      await _textService.addText(this.bookId, this.textTitle, this.textBody);
    } else {
      await _textService.updateText(
          this.bookId, this.textId, this.textTitle, this.textBody);
          await _sentenceService.updateSentencesOfText(textId, sentences.map((e) => e.english).toList());
    }
  }

  void collectSentences() {
    this.sentences.clear();
    //去除句首的姓名
    var text = _textBody.replaceAll(RegExp(r"^.*:", multiLine: true), "");
    var cs =
        RegExp(r"[a-zA-Z0-9,\s\']+[\.?!]", multiLine: true).allMatches(text);
    for (RegExpMatch c in cs) {
      var eng = c.group(0).trim();
      var cnIndex = oldSentences.indexWhere((e) => e.english == eng);
      if (cnIndex >=0 ) {
        sentences.add(oldSentences[cnIndex]);
      } else {
        sentences.add(Sentence(english: eng));
      }
      print("aa " + eng);
    }
    //  this.sentences = [];
    this.notifyListeners();
  }
}
