import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolbox/core/shared_preferences.dart';
import 'package:toolbox/gen/strings.g.dart';
import 'package:toolbox/hierarchy.dart';
import 'package:toolbox/pages/home_page.dart';
import 'package:toolbox/pages/credits_page.dart';
import 'package:toolbox/widgets/main_banner_ad_widget.dart';

class MainShellPage extends StatefulWidget {
  final bool isFolderView;

  const MainShellPage({super.key, required this.isFolderView});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  late int selectedIndex;

  Future<void> onTabSelected(int index) async {
    setState(() {
      selectedIndex = index;
    });
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(SHARED_PREFERENCES_CORE_HOMEPAGE_ISFOLDERVIEW, index == 1);
  }

  @override
  void initState() {
    selectedIndex = widget.isFolderView ? 1 : 0;
    super.initState();
  }

  List<HomePage> get homepages => [
    HomePage(
        key: const Key('tools_view_homepage'),
        content: Hierarchy.getFlatHierarchy()
    ),
    HomePage(
        key: const Key('folders_view_homepage'),
        content: Hierarchy.hierarchy,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(t.generic.app_name),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: colorScheme.surfaceTint,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreditsPage()),
                );
              },
            ),
          ],
        ),
        body: homepages[selectedIndex],
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Platform.isAndroid) const MainBannerAd(),
            NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onTabSelected,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  label: t.generic.tools,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.folder_copy_outlined),
                  label: t.generic.categories,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
