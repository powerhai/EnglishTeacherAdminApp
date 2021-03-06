import 'dart:math';

import 'package:finger_manager_app/domain/icon.dart';
import 'package:finger_manager_app/domain/pages.dart';
import 'package:finger_manager_app/models/book.dart';
import 'package:finger_manager_app/services/yaml_config_service.dart';
import 'package:finger_manager_app/views/cnx_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'vm_book.dart';

class PgBook extends StatefulWidget {
  PgBook({Key key}) : super(key: key);

  @override
  _PgBookState createState() => _PgBookState();
}

class _PgBookState extends State<PgBook> {
  @override
  void initState() {
    super.initState();
    // Future.microtask(() {
    // this.vm.loadBookFamily();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<VmBook>(create: (BuildContext context) async {
      var vm = new VmBook();
      await vm.loadBookFamily();
      return vm;
    }, child: Consumer<VmBook>(
        builder: (BuildContext context, VmBook value, Widget child) {
      return Scaffold(
          appBar: buildAppBar(),
          body: buildBody(),
          floatingActionButton: FloatingActionButton(
              mini: true,
              onPressed: () async {
                var rv = await Navigator.pushNamed(
                  context,
                  "/BookDetail",
                );
                await Future.delayed(Duration(milliseconds: 200));
                value.loadBookFamily();
              },
              child: Icon(Icons.add, color: Colors.white)));
    }));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Book",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      primary: true,
      titleSpacing: 0.0,
    );
  }

  Widget buildBody() {
    return Consumer<VmBook>(
      builder: (BuildContext context, VmBook value, Widget child) {
        if (value == null) return Text("loading...");
        var cnp = ChangeNotifierProvider<VmBook>.value(
            value: value,
            child: Consumer<VmBook>(
                builder: ((BuildContext context, VmBook vm, Widget child) {
              var cs = CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[],
              );

              if (vm != null) {
                for (var family in vm.bookFamilies) {
                  cs.slivers.add(buildRowFamily(family, onDelete: (d) async {
                    try {
                      await vm.deletePublisher(family);
                    } catch (e) {
                      print(e);
                      var sb = SnackBar(content: Text("删除失败"));
                      Scaffold.of(context).showSnackBar(sb);
                    }
                  }));
                  for (var book in family.books) {
                    cs.slivers.add(buildRowBook(book, onDelete: (d) {
                      vm.deleteBook(book);
                    }));
                  }
                }
              }
              return cs;
            })));
        return cnp;
      },
    );
  }

  Widget buildDragTargetFamily(BookPublisher publisher, Widget familyChild) {
    return Consumer<VmBook>(
      builder: (BuildContext context, VmBook value, Widget child) {
        return DragTarget<Book>(builder: (BuildContext context,
            List<dynamic> candidateData, List<dynamic> rejectedData) {
          if (candidateData.length > 0) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Color.fromRGBO(0xea, 0x99, 0x99, 0.4), BlendMode.srcATop),
              child: familyChild,
            );
          }
          return familyChild;
        }, onWillAccept: (b) {
          return true;
        }, onAccept: (b) {
          value.moveBookToPublisher(b, publisher);
        });
      },
    );
  }

  Widget buildRowFamilyBody(BookPublisher family) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[300], boxShadow: [
        BoxShadow(
            color: Colors.black26,
            offset: Offset(3.0, 3.0), //阴影xy轴偏移量
            blurRadius: 15.0, //阴影模糊程度
            spreadRadius: 1.0 //阴影扩散程度
            )
      ]),
      child: Builder(
        builder: (ctx) {
          return CnxListTile(
              backgroundColor: Colors.grey[200],
              leading: Icon(
                FingerIcons.book,
                size: 15,
                color: Theme.of(context).primaryColor,
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, size: 15, color: Colors.grey[700]),
                onPressed: () {
                  editFamilyName(family, ctx);
                },
              ),
              title: ChangeNotifierProvider<BookPublisher>.value(
                value: family,
                builder: (context, child) {
                  return Consumer<BookPublisher>(
                    builder: (BuildContext context, BookPublisher value,
                        Widget child) {
                      return Text(value.title);
                    },
                  );
                },
                child: Text(""),
              ));
        },
      ),
    );
  }

  Widget buildRowFamily(BookPublisher family,
      {DismissDirectionCallback onDelete}) {
    return SliverPersistentHeader(
      pinned: false,
      floating: false,
      delegate: HeaderDelegate(
        child: buildDismissRow<BookPublisher>(
            family,
            buildDragTargetFamily(family, buildRowFamilyBody(family)),
            onDelete),
        maxHeight: 40,
        minHeight: 40,
      ),
    );
  }

  Widget buildDragTargetBook(
    Book book,
    Widget bookChild,
  ) {
    return Consumer<VmBook>(
      builder: (BuildContext context, VmBook value, Widget child) {
        return DragTarget<Book>(builder: (BuildContext context,
            List<Book> candidateData, List<dynamic> rejectedData) {
          if (candidateData.length > 0) {
            return ColorFiltered(
              colorFilter: ColorFilter.mode(
                  Color.fromRGBO(0xB6, 0xd7, 0xa8, 0.4), BlendMode.srcATop),
              child: bookChild,
            );
          }
          return bookChild;
        }, onWillAccept: (b) {
          return true;
        }, onAccept: (b) {
          value.moveBook(b, book);
        });
      },
    );
  }

  Widget buildDraggableBook(Book book, Widget child) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return LongPressDraggable(
        axis: Axis.vertical,
        // ignoringFeedbackSemantics: true,
        data: book,

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
            child:
                Text(book.title, style: Theme.of(context).textTheme.bodyText1),
          ),
        ),
        child: child,
      );
    });
  }

  Widget buildDismissRow<T>(
      T t, Widget child, DismissDirectionCallback onDismiss) {
    return Dismissible(
        background: Container(child: SizedBox(), color: Colors.green),
        secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.all(5),
            child: Icon(FingerIcons.del, color: Colors.white)),
        onDismissed: onDismiss,
        confirmDismiss: (e) async {
          return e == DismissDirection.endToStart;
        },
        key: UniqueKey(),
        child: child);
  }

  Widget buildBookBody(Book book) {
    return Consumer<VmBook>(
      builder: (BuildContext context, VmBook value, Widget child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.grey,
            focusColor: Colors.yellow,
            onTap: () async {
              var rv = await Navigator.pushNamed(context, "/BookDetail",
                  arguments: book);
              await Future.delayed(Duration(milliseconds: 200));
              value.loadBookFamily();
            },
            child: CnxListTile(
              trailing: Icon(FingerIcons.right, size: 15),
              title: Text(book.title),
            ),
          ),
        );
      },
    );
  }

  Widget buildRowBook(Book book, {DismissDirectionCallback onDelete}) {
    return SliverToBoxAdapter(
      child: buildDraggableBook(
          book,
          buildDragTargetBook(
            book,
            buildDismissRow<Book>(
              book,
              buildBookBody(book),
              onDelete,
            ),
          )),
    );
  }

  editFamilyName(BookPublisher family, BuildContext ctx) {
    TextEditingController controller =
        new TextEditingController(text: family.title);

    FocusNode focusNode = new FocusNode();
    showDialog(
        context: ctx,
        builder: (ccc) {
          return new Builder(
            builder: (context2) {
              return AlertDialog(
                title: new Text("更改书册名称"),
                content: new TextField(
                  focusNode: focusNode,
                  controller: controller,
                ),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ctx.read<VmBook>().updateFamily(family, controller.text);
                    },
                    child: new Text("确认"),
                  ),
                  new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("取消"),
                  ),
                ],
              );
            },
          );
        });
    focusNode.requestFocus();
  }

  void gotoAddBookPage() {
    Navigator.pushNamed(context, RoutePages.bookDetail);
  }
}

class HeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  HeaderDelegate(
      {@required this.minHeight,
      @required this.maxHeight,
      @required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => max(minHeight, maxHeight);

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(HeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
