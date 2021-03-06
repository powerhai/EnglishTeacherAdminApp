import 'package:finger_manager_app/models/book.dart';
import 'package:finger_manager_app/services/book_family_service.dart';
import 'package:finger_manager_app/services/book_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmBook with ChangeNotifier {
  BookService _bookService;
  BookPublisherService _publisherService;
  VmBook() {
    _bookService = GetIt.instance.get<BookService>();
    _publisherService = GetIt.instance.get<BookPublisherService>();
  }
  List<BookPublisher> bookFamilies = [];

  Future<void> moveBook(Book from, Book to) async {
    if (from.id == to.id) return;
    BookPublisher fromFamily;
    BookPublisher toFamily;
    for (var family in bookFamilies) {
      if (family.books.any((a) => a.id == from.id)) {
        fromFamily = family;
      }
      if (family.books.any((a) => a.id == to.id)) {
        toFamily = family;
      }
    }
    fromFamily.books.remove(from);
    var index = toFamily.books.indexOf(to);
    toFamily.books.insert(index, from);
    await _bookService.moveBook(from.id , to.id  );
    this.notifyListeners();
  }

  Future<void> moveBookToPublisher(Book book, BookPublisher publisher) async {
    BookPublisher fromFamily;
    for (var family in bookFamilies) {
      if (family.books.any((a) => a.id == book.id)) {
        fromFamily = family;
      }
    }
    if(fromFamily.id == publisher.id)
      return;
    fromFamily.books.remove(book);
    publisher.books.add(book);
    await _bookService.moveBookToPublisher(book.id , publisher.id );
    this.notifyListeners();
  }

  Future<void> deleteBook(Book book) async {
    await _bookService.deleteBook(book.id);
    for (var family in bookFamilies) {
      if (family.books.any((b) => b == book)) {
        family.books.remove(book);
      }
    }
    this.bookFamilies = this.bookFamilies;
    this.notifyListeners();
  }

  Future<void> deletePublisher(BookPublisher publisher) async {
    try {
      await this._publisherService.delPublisher(publisher.id);
      this.bookFamilies.remove(publisher);
    } catch (e) {
      print(e);
      throw e;
    }
    finally{
      this.notifyListeners();
    }

  }

  Future<void> updateFamily(BookPublisher family, String newName) async {
    if (family.title == newName) return;
    try {
      var rv = await _publisherService.updatePublisher(family.id, newName);
      if (rv == false) return;
      family.updateTitle(newName);
    } catch (e) {
      throw e;
    }
  }

  Future<void> loadBooksOfPublisher(BookPublisher publisher) async {
    try {
      var books = await _bookService.getBooksOfPublisher(publisher.id);
      for (var b in books) {
        print("book:${b.title}");
        publisher.books.add(b);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadBookFamily() async {
    print("loadPublisher");
    bookFamilies.clear();
    var ps = await _publisherService.getPublishers();
    for (var p in ps) {
      print("publisher: ${p.title}");
      bookFamilies.add(p);
      await loadBooksOfPublisher(p);
    }
    this.bookFamilies = bookFamilies;
    this.notifyListeners();
  }
}
