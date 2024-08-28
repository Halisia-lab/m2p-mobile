import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../services/report.dart';

class Badges extends StatefulWidget {
  const Badges({super.key});

  static const String routeName = '/badge';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Badges> createState() => _BadgesState();
}

class _BadgesState extends State<Badges> {
  List<MapEntry<String, int>> reportBadgeList = [
    MapEntry('images/report-badge1.png', 1),
    MapEntry('images/report-badge2.png', 10),
    MapEntry('images/report-badge3.png', 50),
    MapEntry('images/report-badge4.png', 100),
    MapEntry('images/report-badge5.png', 150),
    MapEntry('images/report-badge6.png', 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes badges'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signalements',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            buildFutureBuilderBadgeList(),
          ],
        ),
      ),
    );
  }

  FutureBuilder buildFutureBuilderBadgeList() {
    return FutureBuilder(
      future: _getNbReports(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              final data = snapshot.data;
              if (data == null) {
                return Center(
                  child: Text(
                    'Nous n\'avons pas pu récupéré vos données 😵‍💫',
                  ),
                );
              }
              return buildBadgeItem(snapshot.data);
            }
            return Text('${snapshot.error}');
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  SizedBox buildBadgeItem(data) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 140.0,
        ),
        itemCount: reportBadgeList.length,
        itemBuilder: (BuildContext context, int index) {
          bool isImageGreyedOut = reportBadgeList[index].value > data;
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    ColorFiltered(
                      colorFilter: isImageGreyedOut
                          ? ColorFilter.matrix([
                              0.2,
                              0.2,
                              0.2,
                              0.0,
                              0.0,
                              0.2,
                              0.2,
                              0.2,
                              0.0,
                              0.0,
                              0.2,
                              0.2,
                              0.2,
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                              1.0,
                              0.0,
                            ])
                          : ColorFilter.mode(
                              Colors.transparent, BlendMode.srcOver),
                      child: Image.asset(
                        reportBadgeList[index].key,
                        width: 100.0,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearPercentIndicator(
                    width: 100,
                    lineHeight: 20.0,
                    percent: data > reportBadgeList[index].value
                        ? 1
                        : data / reportBadgeList[index].value,
                    center: Text(data.toString() +
                        '/' +
                        reportBadgeList[index].value.toString()),
                    progressColor: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future _getNbReports() async {
    try {
      var token = await storage.read(key: 'token');
      return await ReportService.getUserNbReports(token!);
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
        context,
        "Nous n'avons pas pu charger votre historique.",
        "Veuillez réessayer plus tard.",
      );
    }
  }
}
