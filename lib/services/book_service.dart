import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:finger_manager_app/common/dio_http_helper.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:get_it/get_it.dart';
import 'yaml_config_service.dart';

class BookService {
  String _serverAddress;
  bool _loaded = false;
  static const String ApiGetBooksOfPublisher = "book/GetBooksOfPublisher";
  static const String ApiDelBook = "book/DelBook";
  static const String ApiGetBook = "book/GetBook";
  static const String ApiUpdateBook = "book/UpdateBook";
  static const String ApiMoveBook = "book/MoveBook";
  static const String ApiMoveBookToPublisher = "book/MoveBookToPublisher";
  static const String ApiAddBook = "book/AddBook";

  Future<BookService> init() async {
    if (_loaded) return this;
    ConfigService config = await GetIt.instance.getAsync<ConfigService>();
    _serverAddress = config.serverBaseUrl;
    _loaded = true;
    return this;
  }

  Future<List<Book>> getBooksOfPublisher(int publisherId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${BookService.ApiGetBooksOfPublisher}?publisherId=${publisherId}');

    var res = await dio.getUri(uri,
        options: buildCacheOptions(Duration(minutes: 10),
            primaryKey: ApiGetBooksOfPublisher,
            subKey: publisherId.toString(),
            maxStale: Duration(days: 30)));
    var rd = res.data as List;
    var ps = rd.map((v) => Book.fromJson(v)).toList();
    return ps;
  }

  Future<Book> getBook(int bookId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    dio.interceptors.add(DioHelper.getCacheManager().interceptor);
    var uri = Uri.parse(
        '${this._serverAddress}/${BookService.ApiGetBook}?bookId=${bookId.toString()}');
    var res = await dio.getUri(uri,
        options: buildCacheOptions(Duration(minutes: 10),
            primaryKey: ApiGetBook,
            subKey: bookId.toString(),
            maxStale: Duration(days: 30)));
    var rv = Book.fromJson(res.data);
    return rv;
  }

  Future<bool> addBook(String title, String publisher) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${BookService.ApiAddBook}');
    FormData formData = new FormData.fromMap({"title": title, "publisher": publisher });
    var res = await dio.postUri(uri, data: formData);
    await deleteCache();
    return res.statusCode == 200;
  }

  Future<bool> deleteBook(int bookId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${BookService.ApiDelBook}');
    FormData formData = new FormData.fromMap({"bookId": bookId});
    var res = await dio.postUri(uri, data: formData);
    await deleteCache();
    return res.statusCode == 200;
  }

  Future<bool> moveBook(int fromBookId, int toBookId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${BookService.ApiMoveBook}');
    FormData formData = new FormData.fromMap({"fromBookId": fromBookId, "toBookId": toBookId});
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager().delete(ApiGetBooksOfPublisher);
    return res.statusCode == 200;
  }

  Future<bool> moveBookToPublisher(int fromBookId, int toPublisherId) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${BookService.ApiMoveBookToPublisher}');
    FormData formData = new FormData.fromMap({"fromBookId": fromBookId, "toPublisherId": toPublisherId});
    var res = await dio.postUri(uri, data: formData);
    await DioHelper.getCacheManager().delete(ApiGetBooksOfPublisher);
    return res.statusCode == 200;
  }


  Future<bool> updateBook(
      int bookId, String title, String publisherName) async {
    var dio = new Dio(BaseOptions(responseType: ResponseType.json));
    var uri = Uri.parse('${this._serverAddress}/${BookService.ApiUpdateBook}');
    FormData formData = new FormData.fromMap({
      "bookId": bookId,
      "title": title,
      "publisher": publisherName,
    });
    var res = await dio.postUri(uri, data: formData);
    await deleteCache();
    await DioHelper.getCacheManager()
        .delete(ApiGetBook, subKey: bookId.toString());
    return res.statusCode == 200;
  }

  Future<void> deleteCache() async {
    await DioHelper.getCacheManager().delete(ApiGetBooksOfPublisher);
    await DioHelper.getCacheManager().delete("publisher/GetAllPublishers");
  }
}
