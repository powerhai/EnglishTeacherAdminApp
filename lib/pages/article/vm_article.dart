import 'dart:isolate';
import 'package:audiocutter/audiocutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:finger_manager_app/services/translate_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmArticle extends ChangeNotifier {
  VmArticle(this.bookId, this.operationType, {this.textId});
  int bookId;
  int textId;

  NavigationOperationType operationType;

  String articleBody = "";
}
