class DisplayBook {
  int id;
}

class SentencesUpdateNavigationArguments{ 
  int textId;
  SentencesUpdateNavigationArguments(this.textId);
}
class TextNavigationArguments {
  int bookId;
  int textId;
  NavigationOperationType operationType;

  TextNavigationArguments(this.bookId, this.operationType, {this.textId});
}

enum NavigationOperationType { Add, Update }
