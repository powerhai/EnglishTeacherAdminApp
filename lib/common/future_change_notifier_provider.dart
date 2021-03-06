import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FutureChangeNotifierProvider<T extends ChangeNotifier>
    extends FutureProvider<T> {
  FutureChangeNotifierProvider(
      {Key key,
      @required Create<Future<T>> create,
      T initialData,
      ErrorBuilder<T> catchError,
      UpdateShouldNotify<T> updateShouldNotify,
      bool lazy,
      final Widget Function(BuildContext context, T value) builder})
      : super(
            key: key,
            lazy: lazy,
            create: create,
            updateShouldNotify: updateShouldNotify,
            child: Consumer<T>(builder: (context, vm, cld) {
              return ChangeNotifierProvider<T>.value(
                  value: vm, child: builder(context, vm));
            }));
}
