import 'package:finger_manager_app/models/student.dart';
import 'package:finger_manager_app/services/student_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class VmStudent with ChangeNotifier {
  bool hasMore = true;
  StudentService studentService;
  List<StudentLight> students = [];
  init() {
    if (studentService == null)
      studentService = GetIt.instance.get<StudentService>();
  }

Future<void> refresh() async {
  this.students.clear();
   await loadData();
}
  Future<bool> loadData() async {
    var s = await studentService.getStudents();
    for (var st in s.students) {
      students.add(st);
    }
    hasMore = students.length < 50;
    this.notifyListeners();
    return true;
  }
}
