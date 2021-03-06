import 'package:async/async.dart';
import 'package:finger_manager_app/models/article.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:finger_manager_app/services/book_family_service.dart';
import 'package:finger_manager_app/services/book_service.dart';
import 'package:finger_manager_app/services/text_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmBookDetail with ChangeNotifier {
  BookPublisherService publisherService;
  final AsyncMemoizer<List<String>> memoizer = AsyncMemoizer<List<String>>();
  TextService _textService;
  BookService _bookService;

  VmBookDetail({this.bookId}) {
    publisherService = GetIt.instance.get<BookPublisherService>();
    _textService = GetIt.instance.get<TextService>();
    _bookService = GetIt.instance.get<BookService>();
  }

  Future initPublishers() async {
    var rv = await publisherService.getPublishers();
    this.publishers = rv.map((e) => e.title).toList();
  }

  Future initArticles() async {
    if (this.bookId == null) {
      return;
    }
    texts.clear();
    await Future.delayed(Duration(seconds: 1));
    try {
      var rv = await _textService.getTextsOfBook(bookId);
      rv.sort((a,b)=>a.sort - b.sort);
      texts.addAll(rv);

    } catch (e) {
      print(e);
    }
    this.notifyListeners();
  }

  Future initBookInfo() async {
    if (this.bookId == null) {
      return;
    }
    Book b = await _bookService.getBook(bookId);
    this.bookName = b.title;
    this.bookPublisher = b.publisherName;
    this.notifyListeners();
  }

  int bookId;
  String bookName = "";
  String bookPublisher = "";
  List<TextLight> texts = [];

  List<String> publishers = [];

  deleteArticle(TextLight article) async {
    this.texts.remove(article);
    await _textService.removeText(bookId, article.id);
    this.notifyListeners();
  }

  Future<void> moveArticle(TextLight b, TextLight article) async {
    if (b.id == article.id) return;
    texts.remove(b);
    var index = this.texts.indexOf(article);
    this.texts.insert(index, b);
    await _textService.moveText(bookId, b.id, article.id);
    this.notifyListeners();
  }

  Future saveBookInfo(String title, String publisher) async {
    if (bookId != null) {
      _bookService.updateBook(bookId, title, publisher);
    } else {
      _bookService.addBook(title, publisher);
    }
  }

  void addArticle() {
    this.texts.add(TextLight(title: "okokok"));
    this.notifyListeners();
  }
}
