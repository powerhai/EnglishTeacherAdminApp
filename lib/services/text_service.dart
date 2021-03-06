import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:finger_manager_app/common/dio_http_helper.dart';
import 'package:finger_manager_app/models/article.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:get_it/get_it.dart';
import 'yaml_config_service.dart';

class TextService {
  bool _loaded = false;
  String _serverAddress;
  static const String ApiGetTextsOfBook = "text/GetTextsOfBook";
  static const String ApiGetText = "text/GetText";
  static const String ApiUpdateText = "text/UpdateText";
  static const String ApiAddText = "text/CreateNewText";
  static const String ApiRemoveText = "text/RemoveText";
  static const String ApiMoveText = "text/MoveText";

  Future<TextService> init() async {
    if (_loaded) return this;
    var config = await GetIt.instance.getAsync<ConfigService>();
    _serverAddress = config.serverBaseUrl;
    _loaded = true;
    return this;
  }

  Future<List<TextLight>> getTextsOfBook(int bookId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${TextService.ApiGetTextsOfBook}?bookId=${bookId}');
    Response res;
    res = await dio.getUri(uri,
        options: buildCacheOptions(Duration(minutes: 10),
            primaryKey: TextService.ApiGetTextsOfBook,
            subKey: bookId.toString(),
            maxStale: Duration(days: 30)));
    var rd = res.data as List;
    var ps = rd.map((v) => TextLight.fromJson(v)).toList();
    return ps;
  }

  Future<EnglishText> getText(int textId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${TextService.ApiGetText}?textId=${textId.toString()}');

    var res = await dio.getUri(uri,
        options: buildCacheOptions(Duration(minutes: 10),
            primaryKey: TextService.ApiGetText,
            subKey: textId.toString(),
            maxStale: Duration(days: 30)));
    var rv = EnglishText.fromJson(res.data);
    return rv;
  }

  Future<bool> updateText(
      int bookId, int textId, String title, String body) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${TextService.ApiUpdateText}');
    FormData formData = new FormData.fromMap({
      "TextId": textId,
      "Title": title,
      "Body": body,
    });
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager()
        .delete(TextService.ApiGetText, subKey: textId.toString());
    await DioHelper.getCacheManager()
        .delete(TextService.ApiGetTextsOfBook, subKey: bookId.toString());
    return res.statusCode == 200;
  }

  Future<bool> addText(int bookId, String title, String body) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${TextService.ApiAddText}');
    FormData formData = new FormData.fromMap({
      "BookId": bookId,
      "Title": title,
      "Body": body,
    });
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager()
        .delete(TextService.ApiGetTextsOfBook, subKey: bookId.toString());
    return res.statusCode == 200;
  }

  Future<bool> removeText(int bookId, int textId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${TextService.ApiRemoveText}');
    FormData formData = new FormData.fromMap({"TextId": textId});
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager()
        .delete(TextService.ApiGetTextsOfBook, subKey: bookId.toString());
    return res.statusCode == 200;
  }

  Future<bool> moveText(int bookId, int fromTextId, int toTextId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${TextService.ApiMoveText}');
    FormData formData = new FormData.fromMap({
      "bookId": bookId,
      "fromTextId": fromTextId,
      "toTextId": toTextId,
    });
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager()
        .delete(TextService.ApiGetTextsOfBook, subKey: bookId.toString());
    return res.statusCode == 200;
  }
}
