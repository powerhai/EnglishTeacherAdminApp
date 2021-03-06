import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:finger_manager_app/common/dio_http_helper.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:get_it/get_it.dart';

import 'yaml_config_service.dart';

class BookPublisherService {
  bool _loaded = false;
  String _serverAddress;
  static const String ApiGetAllPublishers = "publisher/GetAllPublishers";
  static const String ApiUpdatePublisher = "publisher/UpdatePublisher";
  static const String ApiDelPublisher = "publisher/DelPublisher";

  Future<BookPublisherService> init() async {
    if (_loaded) return this;
    var config = await GetIt.instance.getAsync<ConfigService>();
    _serverAddress = config.serverBaseUrl;
    _loaded = true;
    Future.delayed(Duration(seconds: 1));
    return this;
  }

  Future<List<BookPublisher>> getPublishers() async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${BookPublisherService.ApiGetAllPublishers}');
    var res = await dio.getUri(uri,
        options: buildCacheOptions(
            Duration(
              minutes: 10,
            ),
            primaryKey: ApiGetAllPublishers,
            maxStale: Duration(days: 30)));
    var rd = res.data as List;
    var ps = rd.map((v) => BookPublisher.fromJson(v)).toList();
    return ps;
  }

  Future<bool> updatePublisher(int id, String title) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse(
        '${this._serverAddress}/${BookPublisherService.ApiUpdatePublisher}');
    FormData formData = new FormData.fromMap({
      "Id": id,
      "Title": title,
    });

    var res = await dio.postUri(uri, data: formData);
    return res.statusCode == 200;
  }

  Future<bool> delPublisher(int id) async {
    var dio = new Dio(BaseOptions(
        responseType: ResponseType.json,
        sendTimeout: 10000,
        connectTimeout: 10000,
        receiveTimeout: 10000));
    var uri = Uri.parse(
        '${this._serverAddress}/${BookPublisherService.ApiDelPublisher}');
    FormData formData = new FormData.fromMap({
      "Id": id,
    });
    var res = await dio.postUri(uri, data: formData);
    DioHelper.getCacheManager()
        .delete(BookPublisherService.ApiGetAllPublishers);
    return res.statusCode == 200;
  }
}

class ResPublishersData {
  List<BookPublisher> transResult;

  ResPublishersData({this.transResult});

  factory ResPublishersData.fromJson(Map<String, dynamic> json) {
    var list = json['trans_result'] as List;

    return ResPublishersData();
  }
}
