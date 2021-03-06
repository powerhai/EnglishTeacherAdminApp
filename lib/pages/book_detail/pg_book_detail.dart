import 'package:finger_manager_app/common/navigator_arguments.dart';
import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/domain/pages.dart';
import 'package:finger_manager_app/models/article.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:finger_manager_app/views/cnx_card.dart';
import 'package:finger_manager_app/views/cnx_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../publisher_provider.dart';
import 'vm_book_detail.dart';

class PgBookDetail extends StatefulWidget {
  PgBookDetail({Key key}) : super(key: key);

  @override
  _PgBookDetailState createState() => _PgBookDetailState();
}

class _PgBookDetailState extends State<PgBookDetail> {
  @override
  void dispose() {
    super.dispose();
  }

  void _saveBookInfo(VmBookDetail vm) {
    var title = _bookTitleTextcontroller.text;
    var publisher = _publisherTextController.text;
    vm.saveBookInfo(title, publisher);
    Navigator.pop(context);
  }

  Book _book;
  TextEditingController _publisherTextController = TextEditingController();
  TextEditingController _bookTitleTextcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _book = ModalRoute.of(context).settings.arguments;

    return ChangeNotifierProvider<VmBookDetail>(
      create: (BuildContext context) {
        if (_book != null)
          return VmBookDetail(bookId: _book.id);
        else
          return VmBookDetail();
      },
      child:
          Material(child: Scaffold(appBar: buildAppBar(), body: buildBody())),
    );
  }

  Widget buildBody() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildGroupBook(),
          Expanded(child: buildGroupTexts()),
          buildRowSaveButton()
        ]);
  }

  Widget buildRowDraggable(TextLight article, Widget child) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return LongPressDraggable(
          axis: Axis.vertical,
          data: article,
          childWhenDragging: SizedBox(),
          feedback: Opacity(
            opacity: 0.7,
            child: Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(3.0, 3.0),
                    blurRadius: 8.0,
                    spreadRadius: 1.0)
              ]),
              height: 40,
              width: constraints.maxWidth,
              padding: EdgeInsets.all(10.0),
              child: Text(article.title,
                  style: Theme.of(context).textTheme.bodyText1),
            ),
          ),
          child: child);
    });
  }

  Widget buildDragTargetArticle(TextLight article, Widget tgchild) {
    return Consumer<VmBookDetail>(
        builder: (BuildContext context, VmBookDetail vm, Widget child) {
      return DragTarget<TextLight>(
        builder: (BuildContext context, List<TextLight> candidateData,
            List<dynamic> rejectedData) {
          if (candidateData.length > 0) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Color.fromRGBO(0xB6, 0xd7, 0xa8, 0.4), BlendMode.srcATop),
              child: tgchild,
            );
          }
          return tgchild;
        },
        onWillAccept: (b) {
          return true;
        },
        onAccept: (b) {
          vm.moveArticle(b, article);
        },
      );
    });
  }

  Widget buildRowDismiss(TextLight article, Widget child) {
    return Builder(
      builder: (ctx) {
        return Dismissible(
            background: Container(child: SizedBox(), color: Colors.green),
            secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(5),
                child: Icon(FingerIcons.del, color: Colors.white)),
            onDismissed: (d) {
              Provider.of<VmBookDetail>(ctx, listen: false)
                  .deleteArticle(article);
            },
            confirmDismiss: (e) async {
              return e == DismissDirection.endToStart;
            },
            key: UniqueKey(),
            child: child);
      },
    );
  }

  Widget buildRowArticle(TextLight article) {
    return Consumer<VmBookDetail>(
      builder: (context, vm, cld) {
        return InkWell(
          onTap: () async {
            var rv = await Navigator.pushNamed(
                context, RoutePages.articleDetail,
                arguments: new TextNavigationArguments(
                    vm.bookId, NavigationOperationType.Update,
                    textId: article.id));
            await vm.initArticles();
          },
          child: CnxListTile(
            title: Text(article.title),
            trailing: Icon(FingerIcons.right, size: 15),
          ),
        );
      },
    );
  }

  Widget buildGroupTexts() {
    return Consumer<VmBookDetail>(
      builder: (context, vm, cld) {
        return Offstage(
          offstage: vm.bookId == null,
          child: CnxCard(
            leading: Icon(
              FingerIcons.book,
              size: 16,
              color: Colors.grey,
            ),
            header: "Articles",
            headerButton: Material(
              color: Colors.transparent,
              child: Container(
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(FingerIcons.add, color: Colors.lightGreen),
                  onPressed: () {
                    Navigator.pushNamed(context, RoutePages.articleDetail,
                        arguments: new TextNavigationArguments(
                            vm.bookId, NavigationOperationType.Add));
                  },
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Builder(
                builder: (ctx) {
                  return FutureProvider<List<TextLight>>(
                    create: (BuildContext context) async {
                      var vm = Provider.of<VmBookDetail>(ctx);
                      await vm.initArticles();
                      return vm.texts;
                    },
                    child: Consumer<List<TextLight>>(
                      builder: (BuildContext context, List<TextLight> value,
                          Widget child) {
                        if (value == null)
                          return Text("Loading...");
                        else
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: value
                                .map((e) => buildDragTargetArticle(
                                    e,
                                    buildRowDraggable(
                                        e,
                                        buildRowDismiss(
                                            e, buildRowArticle(e)))))
                                .toList(),
                          );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildRowSaveButton() {
    return Consumer<VmBookDetail>(
      builder: (BuildContext context, VmBookDetail value, Widget child) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 8.0, bottom: 8.0, right: 8.0),
          child: RaisedButton(
              color: Colors.lightGreen,
              onPressed: () {
                _saveBookInfo(value);
              },
              child: Text("SAVE")),
        );
      },
    );
  }

  Widget buildGroupBook() {
    return Builder(builder: (BuildContext ctx) {
      return Consumer<VmBookDetail>(
        builder: (BuildContext context, VmBookDetail v, Widget child) {
          return FutureProvider<VmBookDetail>(
              create: (BuildContext context) async {
                await v.initBookInfo();
                return v;
              },
              child: CnxCard(
                  leading: Icon(FingerIcons.book, size: 16, color: Colors.grey),
                  header: "Book",
                  headerButton: SizedBox(),
                  body: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        buildRowBookName(),
                        buildRowFamily(),
                      ])));
        },
      );
    });
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text("Book Detail",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      centerTitle: true,
      primary: true,
      titleSpacing: 0.0,
    );
  }

  Widget buildRowFamily() {
    return Builder(
      builder: (ctx) {
        return Consumer<VmBookDetail>(
            builder: (BuildContext context, VmBookDetail v, Widget child) {
          if (v == null)
            return Text("Loading...");
          else {
            _publisherTextController.text = v.bookPublisher;
            return TextField(
                controller: _publisherTextController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontSize: 13),
                  labelText: "Book Family",
                  suffixIcon: FutureProvider<List<String>>(
                      create: (BuildContext ctx2) async {
                    var vm = ctx.read<VmBookDetail>();
                    if (vm == null) return [];
                    await vm.initPublishers();
                    return vm.publishers;
                  }, child: Consumer<List<String>>(
                    builder: (BuildContext context, value, Widget child) {
                      if (value != null) {
                        return PopupMenuButton(
                          onSelected: (s) {
                            _publisherTextController.text = s;
                          },
                          icon: InkWell(child: Icon(Icons.arrow_drop_down)),
                          itemBuilder: (BuildContext context) {
                            List<PopupMenuItem<String>> g = [];

                            value.forEach((String c) {
                              g.add(PopupMenuItem(
                                child: Text(c),
                                value: c,
                              ));
                            });
                            return g;
                          },
                        );
                      } else {
                        return SizedBox(
                            width: 3.1,
                            height: 3.2,
                            child: new CircularProgressIndicator());
                      }
                    },
                  )),
                  border: UnderlineInputBorder(),
                ));
          }
        });
      },
    );
  }

  Widget buildRowBookName() {
    return Consumer<VmBookDetail>(
      builder: (BuildContext context, VmBookDetail v, Widget child) {
        if (v != null) _bookTitleTextcontroller.text = v.bookName;
        return TextField(
          controller: _bookTitleTextcontroller,
          decoration: new InputDecoration(
              labelText: 'Book Name', labelStyle: TextStyle(fontSize: 13)),
        );
      },
    );
  }
}
