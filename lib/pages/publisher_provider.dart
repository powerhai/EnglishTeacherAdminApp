import 'package:async/async.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:finger_manager_app/services/book_family_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class PublisherProvider  {
  BookPublisherService publisherService; 
  PublisherProvider(){
     publisherService = GetIt.instance.get<BookPublisherService>();
  }
  final AsyncMemoizer<List<BookPublisher>> memoizer = AsyncMemoizer<List<BookPublisher>>();
  bool isLoaded = false;
  List<BookPublisher> publishers = new List<BookPublisher>();
  Future<List<BookPublisher>> getPublishers() async {

    await Future.delayed(Duration(seconds: 5));
    isLoaded = true;
    return memoizer.runOnce (() async {
      var rv = await publisherService.getPublishers();
      publishers = rv;
      return rv ;
    });
  } 
}
