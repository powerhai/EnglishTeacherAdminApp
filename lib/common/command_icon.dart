import 'package:flutter/widgets.dart';

class PageCommand {
  final String title;
  final IconData icon;
  final VoidCallback command;
  PageCommand({this.title, this.icon, this.command});
}
