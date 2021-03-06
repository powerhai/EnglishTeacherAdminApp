import 'dart:isolate';

import 'package:audiocutter/audiocutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:finger_manager_app/services/sentence_service.dart';
import 'package:finger_manager_app/services/text_service.dart';
import 'package:finger_manager_app/services/translate_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmTextSentence extends ChangeNotifier {
  int textId;

  SentenceService _sentenceService;
  TextService _textService;
  VmTextSentence(this.textId) {
    _textService = GetIt.instance.get<TextService>();
    _sentenceService = GetIt.instance.get<SentenceService>();
  }
  List<Sentence> sentences = [];

  Future loadData() async {
    var sens = await _sentenceService.getSentencesOfText(textId);
    this.sentences.addAll(sens);
    this.notifyListeners();
  }

  int position = 0;
  int duration = 100;
  bool isAudioLoaded = false;
  bool isPlaying = false;
  String audioFile = "";
  double audioLength = 0.0;
  AudioPlayer player;
  AudioPlayer sentencePlayer;
  loadAudio(String audioFile) async {
    player?.stop();
    player?.release();
    player?.dispose();
    player = AudioPlayer(playerId: "haiser");

    isAudioLoaded = true;
    this.audioFile = audioFile;
    player.onAudioPositionChanged.listen((p) {
      position = p.inMilliseconds;

      this.notifyListeners();
    });
    player.onPlayerCompletion.listen((p) {
      isPlaying = false;
      this.notifyListeners();
    });
    player.onDurationChanged.listen((p) {
      if (p.inMilliseconds == this.duration) return;
      this.duration = p.inMilliseconds;
      updateAllAudioRange();
      this.notifyListeners();
    });
    var res2 = player.play(this.audioFile, isLocal: true);
    isPlaying = true;
    this.notifyListeners();
  }

  void resume() {
    this.player.resume();
    isPlaying = true;
    this.notifyListeners();
  }

  void stop() {
    isPlaying = false;
    this.player?.stop();
    this.player?.release();
    this.sentencePlayer?.stop();
    this.sentencePlayer?.release();
    this.notifyListeners();
  }

  void pause() {
    isPlaying = false;
    this.player.pause();
    this.notifyListeners();
  }

  void moveTo(int position) {
    this.position = position;
    player.seek(Duration(milliseconds: position));
    this.notifyListeners();
  }

  void updateSentenceAudioRange(Sentence sen, double start, double end) {
    sen.startAudio = start;
    if (sen.endAudio != end) {
      sen.endAudio = end;
      updateSentencesAudioRange(sen);
    }

    this.notifyListeners();
  }

  void updateSentencesAudioRange(Sentence first) {
    var index = sentences.indexOf(first);
    updateSentencesAudioRangeByIndex(index);
  }

  void updateAllAudioRange() {
    double len = 0;
    var unitLen = duration / (sentences.length);
    for (var i = 0; i < sentences.length; i++) {
      var cur = sentences[i];
      cur.startAudio = len;
      var end = len + unitLen;
      cur.endAudio = end > duration ? duration : end;
      len = cur.endAudio;
      cur.isAudioChanged = true;
      cur.audioLocation = AudioLocation.LocalFile;
    }
  }

  void updateSentencesAudioRangeByIndex(int index) {
    var len = sentences[index].endAudio;
    var allLen = this.duration - len;
    var unitLen = allLen / (sentences.length - index - 1);
    for (var i = index + 1; i < sentences.length; i++) {
      var cur = sentences[i];
      cur.startAudio = len;
      var end = len + unitLen;
      cur.endAudio = end > duration ? duration : end;
      len = cur.endAudio;
    }
  }

  void updateSentenceChinese(Sentence sen, String chinese) {
    if (sen.chinese == chinese) return;
    sen.chinese = chinese;
    sen.isChineseChanged = true;
    this.notifyListeners();
  }

  Future<void> playSentenceAudio(Sentence sen) async {
    this.sentencePlayer?.stop();
    this.sentencePlayer?.release();
    var start = sen.startAudio / 1000;
    var end = sen.endAudio / 1000;

    String audioFile = "";
    if (sen.audioLocation == AudioLocation.LocalFile)
      audioFile = await AudioCutter.cutAudio(this.audioFile, start, end);
    else
      audioFile = await _sentenceService.getSentenceAudioUrl(sen.id);
    this.sentencePlayer = new AudioPlayer(playerId: "haiser2");
    this
        .sentencePlayer
        .play(audioFile, isLocal: true );
  }

  void updateAudioStart(Sentence sen, double start) {
    sen.startAudio = start;
    this.notifyListeners();
  }

  void updateSentenceEnd(Sentence sen, double end) {
    sen.endAudio = end;
    this.notifyListeners();
  }

  Future<void> translateSentences() async {
    if (newIsolate == null) {
      ReceivePort receivePort = ReceivePort();
      newIsolate = await Isolate.spawn(
        translateEnter,
        receivePort.sendPort,
      );
      newIsolateSendPort = await receivePort.first;
    }
    for (var sen in this.sentences) {
      await Future.delayed(Duration(seconds: 1));
      String chn = await sendReceive(sen.english);
      updateSentenceChinese(sen, chn);
    }
  }

  static void translateEnter(SendPort callerSendPort) async {
    ReceivePort newIsolateReceivePort = ReceivePort();
    callerSendPort.send(newIsolateReceivePort.sendPort);
    newIsolateReceivePort.listen((dynamic message) async {
      CrossIsolatesMessage incomingMessage = message as CrossIsolatesMessage;
      var str = await incomingMessage.api.translate(incomingMessage.message);
      String newMessage = str;
      incomingMessage.sender.send(newMessage);
    });
  }

  SendPort newIsolateSendPort;
  Isolate newIsolate;

  Future<String> sendReceive(String english) async {
    ReceivePort port = ReceivePort();
    var api = await GetIt.instance.getAsync<BaiduSentenceTranslateService>();
    newIsolateSendPort.send(CrossIsolatesMessage<String>(
        sender: port.sendPort, message: english, api: api));
    var cc = await port.first;
    return cc.toString();
  }

  Future<void> save() async {
    for (var stc in this.sentences) {
      stc.uploadState = UploadState.Normal;
    }
    this.notifyListeners();
    for (var stc in this.sentences) {
      if (stc.isChanged == false) continue;
      stc.uploadState = UploadState.Uploading;
      this.notifyListeners();

      String outputFilePath = "";
      if (stc.isAudioChanged) {
        var start = stc.startAudio / 1000;
        var end = stc.endAudio / 1000;
        outputFilePath = await AudioCutter.cutAudio(this.audioFile, start, end);
      }

      var rev = await _sentenceService.updateSentence(textId, stc,
          audiofile: outputFilePath);

      stc.uploadState = UploadState.Uploaded;
      stc.isChineseChanged = false;
      stc.isAudioChanged = false;
      this.notifyListeners();
    }
  }

  @override
  void dispose() {
    this.player?.stop();
    this.player?.resume();
    this.player?.dispose();
    super.dispose();
  }
}

class CrossIsolatesMessage<T> {
  BaiduSentenceTranslateService api;
  final SendPort sender;
  final T message;
  CrossIsolatesMessage({@required this.sender, this.message, this.api});
}
