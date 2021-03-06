import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_refresh_loadmore/flutter_refresh_loadmore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'vm_student.dart';

class PgStudent extends StatefulWidget {
  PgStudent({Key key}) : super(key: key);

  @override
  _PgStudentState createState() => _PgStudentState();
}

class _PgStudentState extends State<PgStudent> {
  VmStudent vm;
  GlobalKey<ListViewRefreshLoadMoreWidgetState> _listViewKey = new GlobalKey();
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<VmStudent>(context);
    vm.init();

    return Material(
      child: Scaffold(
        appBar: buildAppBar(),
        body: buildBody(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Student",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      primary: true,
      titleSpacing: 0.0,
    );
  }

  Widget buildBody() {
    return Column(
      children: <Widget>[
        buildRowSearchBar(),
        Expanded(
          child: buildStudentList(),
        )
      ],
    );
  }

  Widget buildStudentList() {
    return ListViewRefreshLoadMoreWidget(
      key: _listViewKey,
      itemCount: vm.students.length,
      loadMoreCallback: () async {
        await vm.loadData();
        _listViewKey.currentState.changeData(vm.students.length);
      },
      refrshCallback: () async {
        await vm.refresh();
        _listViewKey.currentState.changeData(vm.students.length);
      },
      swrapInsideWidget: (BuildContext context, int index) {
        return buildRowStudent(context, index);
      },
      hasMoreData: vm.hasMore,
    );
  }

  Widget buildRowStudent(BuildContext context, int index) {
    var student = vm.students[index];
    return Card(
      child: ListTile(
         
        dense: true,
        contentPadding: EdgeInsets.all(1),
        leading: Image.network(student.imgUrl, width: 40, height: 60),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(student.name),
            SizedBox(width: 10),
            Text("${student.age.toString()}岁",
                style: TextStyle(fontSize: 11, color: Colors.green)),
            SizedBox(width: 10),
            Text("${student.wordCount.toString()}词",
                style: TextStyle(fontSize: 11, color: Colors.blue)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(student.school),
            Text(DateFormat("yyyy-MM-dd").format( student.joinDate),
                style: TextStyle(fontSize: 11, color: Colors.grey))
          ],
        ),
        trailing: Icon(FingerIcons.right, size: 15),
      ),
    );
  }

  Widget buildRowSearchBar() {
    return TextField(
      decoration: InputDecoration(
          labelText: "Search",
          hintText: "输入姓名、学校",
          prefixIcon: Icon(Icons.people),
          suffixIcon: Icon(Icons.search)),
    );
  }

  Widget buildFilterBar() {
    return Row(
      children: <Widget>[],
    );
  }
}
