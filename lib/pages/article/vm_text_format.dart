import 'package:finger_manager_app/models/sentence.dart';
import 'package:flutter/widgets.dart';

class VmTextRich extends ChangeNotifier {
  final String textBody;
  List<Sentence> sentences = [];
  VmTextRich(this.textBody,this.sentences);
}
