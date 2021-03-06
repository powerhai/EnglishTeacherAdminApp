import 'package:finger_manager_app/models/student.dart';

class StudentService {
  bool _loaded;

  Future<StudentService> init() async {
    if (_loaded) return this;
    _loaded = true;
    return this;
  }

  Future<StudentSearchResult> getStudents() async {
    await Future.delayed(Duration(seconds: 1));
    var res = new StudentSearchResult(allCount: 100, students: []);
    res.students.add(new StudentLight(
        name: "黄新睿",
        school: "实验学校",
        age: 11,
        wordCount: 122,
        joinDate: DateTime.now(),
        imgUrl:
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1898678601,2494162971&fm=26&gp=0.jpg"));

    res.students.add(new StudentLight(
        name: "黄长睿",
        school: "解放学校",
        age: 8,
        wordCount: 1222,
        joinDate: DateTime(2018, 10, 2),
        imgUrl:
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1948197886,1571319635&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "黄新恬",
        school: "解放学校",
        age: 8,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 322,
        imgUrl:
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3301094433,3195321797&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "应家靖",
        school: "娃哈哈幼儿园",
        age: 18,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 754,
        imgUrl:
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2641260059,1089025816&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "应家依",
        school: "解放学校",
        age: 21,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 666,
        imgUrl:
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=29896599,3804880100&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "张诩诺",
        school: "解放学校",
        age: 9,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 888,
        imgUrl:
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1118776306,653274124&fm=26&gp=0.jpg"));

    res.students.add(new StudentLight(
        name: "黄新睿",
        school: "实验学校",
        age: 11,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 122,
        imgUrl:
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1898678601,2494162971&fm=26&gp=0.jpg"));

    res.students.add(new StudentLight(
        name: "黄长睿",
        school: "解放学校",
        age: 8,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 1222,
        imgUrl:
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1948197886,1571319635&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "黄新恬",
        school: "解放学校",
        age: 8,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 322,
        imgUrl:
            "https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3301094433,3195321797&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "应家靖",
        school: "娃哈哈幼儿园",
        age: 18,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 754,
        imgUrl:
            "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2641260059,1089025816&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "应家依",
        school: "解放学校",
        age: 21,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 666,
        imgUrl:
            "https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=29896599,3804880100&fm=26&gp=0.jpg"));
    res.students.add(new StudentLight(
        name: "张诩诺",
        school: "解放学校",
        age: 9,
        joinDate: DateTime(2018, 10, 2),
        wordCount: 888,
        imgUrl:
            "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1118776306,653274124&fm=26&gp=0.jpg"));

    return res;
  }
}

class StudentSearchResult {
  List<StudentLight> students;
  int allCount;
  StudentSearchResult({this.students, this.allCount = 0});
}
