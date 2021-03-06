import 'package:flutter/widgets.dart';

class BookPublisher with ChangeNotifier {
  String title;
  int id;
  List<Book> books;
  int sort;
  BookPublisher({this.id, this.title, this.books, this.sort = 0});
  factory BookPublisher.fromJson(Map<String, dynamic> json) {
    return BookPublisher(title: json["Title"], id: json["Id"], books: []);
  }

  void updateTitle(String tt) {
    this.title = tt;
    this.notifyListeners();
  }
}

class Book {
  String title;
  int id;
  int sort;
  Book({this.id, this.title, this.sort = 0, this.publisherName = ""});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
        title: json["Title"], id: json["Id"], publisherName: json["PublisherName"]);
  }

  String publisherName;
}

class EnglishText {
  int id;
  String title;
  String body;
  EnglishText({this.id, this.title, this.body});
  factory EnglishText.fromJson(Map<String, dynamic> json) {
    return EnglishText(
        id: json["Id"], title: json["Title"], body: json["Body"]);
  }
}
