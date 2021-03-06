import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:get_it/get_it.dart';
import 'yaml_config_service.dart';

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class BaiduSentenceTranslateService {
  int _number = 0;
  bool _loaded = false;
  String serverPath = "";
  String appId = "";
  String appKey = "";
  BaiduSentenceTranslateService() {}

  String generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  Future<BaiduSentenceTranslateService> init() async {
    if (_loaded) return this;

    var config = GetIt.instance.get<ConfigService>();
    appId = config.baiduClientId;
    appKey = config.baiduClientSecret;
    serverPath = config.baiduBaseUrl;
    _loaded = true;

    Future.delayed(Duration(seconds: 1));
    return this;
  }

  Future<String> translate(String sentence) async {
    //dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: "http://www.google.com")).interceptor);
    var uri = Uri.parse(this.serverPath);
    var number = _number.toString().padLeft(6, '0');
    var sign = generateMd5(appId + sentence + number + appKey);
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));

    var res = await dio.postUri(uri,
        data: FormData.fromMap({
          "q": sentence,
          "from": "en",
          "to": "zh",
          "appid": appId,
          "salt": number,
          "sign": sign
        }));
    this._number++;

    var rd = ResData.fromJson(res.data);
    if (rd.errorMsg != null) {
      throw new Exception(rd.errorMsg);
    }
    return rd.transResult[0]?.dst;
  }
}

class ResData {
  String errorMsg;
  String errorCode;
  String from;
  String to;
  List<TransData> transResult;
  ResData(
      {this.from, this.to, this.transResult, this.errorMsg, this.errorCode});

  factory ResData.fromJson(Map<String, dynamic> json) {
    var list = json['trans_result'] as List;

    List<TransData> cityList = list == null
        ? null
        : list.map((value) => TransData.fromJson(value)).toList();

    return ResData(
        from: json["from"],
        to: json["to"],
        transResult: cityList,
        errorCode: json["error_code"],
        errorMsg: json["error_msg"]);
  }
}

class TransData {
  String src;
  String dst;
  TransData({this.src, this.dst});
  factory TransData.fromJson(Map<String, dynamic> json) {
    return new TransData(src: json["src"], dst: json["dst"]);
  }
}
