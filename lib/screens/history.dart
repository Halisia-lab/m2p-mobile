import 'package:flutter/material.dart';
import 'package:m2p/components/point_history.dart';
import 'package:m2p/components/search_history.dart';

import '../components/report_history.dart';

class History extends StatelessWidget {
  const History({Key? key}) : super(key: key);

  static const String routeName = '/history';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  static const List<Tab> historyTabs = <Tab>[
    Tab(text: 'Recherche'),
    Tab(text: 'Signalement'),
    Tab(text: 'Point'),
  ];

  @override
  Widget build(BuildContext context) {
    TabBar _tabBar = TabBar(
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      tabs: historyTabs,
    );

    return Scaffold(
      body: DefaultTabController(
        length: historyTabs.length,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Historique'),
            bottom: PreferredSize(
              preferredSize: _tabBar.preferredSize,
              child: _tabBar,
            ),
          ),
          body: TabBarView(
            children: [
              SearchHistory(),
              ReportHistory(),
              PointHistory(),
            ],
          ),
        ),
      ),
    );
  }
}
