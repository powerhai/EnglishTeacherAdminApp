import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:oktoast/oktoast.dart'; 
import 'package:provider/provider.dart';
import 'domain/pages.dart';
import 'pages/article/pg_article.dart';
import 'pages/article/vm_article.dart'; 
import 'pages/book_detail/pg_book_detail.dart'; 
import 'pages/home/pg_home.dart';
import 'pages/home/vm_home.dart'; 
import 'pages/settings/vm_settings.dart';
import 'pages/student/vm_student.dart';
import 'pages/text_sentence_detail/pg_text_sentence_detail.dart';
import 'services/register_services.dart'; 
Future<void> main() async {

  Provider.debugCheckInvalidValueType = null;


  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  registerService();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => VmHome()),
      ChangeNotifierProvider(create: (context) => VmStudent()),
      ChangeNotifierProvider(create: (context) => VmSettings())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: FutureBuilder(
        future: GetIt.instance.allReady(),
        builder: (context, state) {
          if (state.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: true,
              title: '指尖英语',
              theme: ThemeData(
                primarySwatch: Colors.lightGreen,
              ),
              initialRoute: "/",
              routes: {
                RoutePages.home: (context) => PgHome(),
                RoutePages.bookDetail: (context) => PgBookDetail(),
                RoutePages.articleDetail: (context) => PgArticle(),
                RoutePages.textSentenceDetail : (context) => PgTextSentenceDetail(),
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
