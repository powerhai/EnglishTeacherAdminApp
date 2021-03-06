import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:finger_manager_app/common/dio_http_helper.dart';
import 'package:finger_manager_app/models/sentence.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import 'yaml_config_service.dart';

class SentenceService {
  bool _loaded = false;
  String _serverAddress;
  static const String ApiGetSntencesOfText = "sentence/GetSentencesOfText";
  static const String ApiUpdateSentencesOfText =
      "sentence/UpdateSentencesOfText";
  static const String ApiUpdateSentence = "sentence/UpdateSentence";
  static const String ApiGetAudio = "sentence/GetAudio";

  Future<SentenceService> init() async {
    if (_loaded) return this;
    var config = await GetIt.instance.getAsync<ConfigService>();
    _serverAddress = config.serverBaseUrl;
    _loaded = true;
    return this;
  }

  Future<List<Sentence>> getSentencesOfText(int textId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${SentenceService.ApiGetSntencesOfText}?textId=${textId.toString()}');
    Response res;
    res = await dio.getUri(uri,
        options: buildCacheOptions(Duration(minutes: 10),
            primaryKey: SentenceService.ApiGetSntencesOfText,
            subKey: textId.toString(),
            maxStale: Duration(days: 30)));
    var rd = res.data as List;
    var ps = rd.map((v) => Sentence.fromJson(v)).toList();
    return ps;
  }

  Future<bool> updateSentencesOfText(int textId, List<String> english) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse(
        '${this._serverAddress}/${SentenceService.ApiUpdateSentencesOfText}');
    FormData formData = new FormData.fromMap({
      "TextId": textId,
      "Eng": english,
    });
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager().delete(
        SentenceService.ApiGetSntencesOfText,
        subKey: textId.toString());
    return res.statusCode == 200;
  }

  Future<bool> updateSentence(int textId, Sentence sentence,
      {String audiofile}) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse(
        '${this._serverAddress}/${SentenceService.ApiUpdateSentence}');
    FormData formData;

    if (sentence.isAudioChanged) {
      formData = new FormData.fromMap({
        "TextId": textId,
        "Eng": sentence.english,
        "Chn": sentence.chinese,
        "Audio": await MultipartFile.fromFile(audiofile, filename: "abc.mp3"),
        "AudioFileName": "abc.mp3"
      });
    } else {
      formData = new FormData.fromMap(
          {"TextId": textId, "Eng": sentence.english, "Chn": sentence.chinese});
    }

    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager().delete(
        SentenceService.ApiGetSntencesOfText,
        subKey: textId.toString());
    return res.statusCode == 200;
  }

  Future<String> getSentenceAudioUrl(int sentenceId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.bytes));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var directory = await getTemporaryDirectory();
    var filepath = '${directory.path}\\sen_${sentenceId.toString()}.mp3';
    var uri =
        '${this._serverAddress}/${SentenceService.ApiGetAudio}?sentenceId=${sentenceId.toString()}';
    var res = await dio.download(uri, filepath 
         );
   
    return filepath;
  }
}
