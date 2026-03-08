import 'dart:core';
import 'package:flutter/material.dart';
import 'package:toolbox/models/home_tool.dart';
import 'package:toolbox/pages/folder_page.dart';

class HomeFolder {
  String name;
  String image;
  bool isFavoriteFolder = false;
  List<HomeTool?> content;
  late Widget page;

  HomeFolder(this.name, this.image, this.content, {this.isFavoriteFolder = false}) {
    content.removeWhere((tool) => tool == null);
    page = FolderPage(title: name, content: content);
  }
}
