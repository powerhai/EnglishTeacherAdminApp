import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/pages/book/pg_book.dart';
import 'package:finger_manager_app/pages/settings/pg_settings.dart'; 
import 'package:finger_manager_app/pages/student/pg_student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'vm_home.dart';

class PgHome extends StatelessWidget {
  PgHome({Key key}) : super(key: key);

  List<PageItem> mPages = [
    PageItem("Heart", "Heart", FingerIcons.heart, PgBook()),
    PageItem("student", "student", FingerIcons.student, PgStudent()),
    PageItem("money", "money", FingerIcons.money, Text("")),
    PageItem("book", "book", FingerIcons.book, Text("")),
    PageItem("Settings", "Settings", FingerIcons.settings, PgSettings()),
  ];

  @override
  Widget build(BuildContext context) {
    var vm = Provider.of<VmHome>(context);
    return Material(
        child: Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: getBottomNavigationBarItems(),
        iconSize: 24.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: vm.selectedIndex,
        onTap: (i) {
          vm.selectPage(i);
        },
        type: BottomNavigationBarType.fixed,
      ),
      body: mPages[vm.selectedIndex].body,

    ));
  }

  List<BottomNavigationBarItem> getBottomNavigationBarItems() {
    List<BottomNavigationBarItem> items = [];
    mPages.forEach((f) {
      items.add(new BottomNavigationBarItem(
        title: Text(f.title),
        icon: getTabImage(f.iconData),
      ));
    });

    return items;
  }

  Icon getTabImage(IconData icon) {
    return new Icon(icon, size: 26.0);
  }
 
 
}

class PageItem {
  String title;
  IconData iconData;
  String name;
  Widget body;
  PageItem(this.title, this.name, this.iconData, this.body);
}
