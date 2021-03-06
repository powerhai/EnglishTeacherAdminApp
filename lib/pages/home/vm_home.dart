import 'package:flutter/widgets.dart';

class VmHome with ChangeNotifier{
  int selectedIndex = 0;

  void selectPage(int index){
    selectedIndex = index;
    this.notifyListeners();
  }

}