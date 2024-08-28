import 'package:flutter/material.dart';
import 'package:m2p/services/vehicle.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../models/user.dart';
import '../models/vehicle.dart';

class ProfileCard extends StatefulWidget {
  final User user;

  const ProfileCard({Key? key, required this.user}) : super(key: key);

  static const List<Tab> profileTabs = <Tab>[
    Tab(text: 'Mon Profil'),
    Tab(text: 'Ma Voiture'),
  ];

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: ProfileCard.profileTabs.length,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * .1,
              child: Card(
                child: Container(
                  width: MediaQuery.of(context).size.width * .7,
                  height: MediaQuery.of(context).size.height * .32,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      TabBar(
                        tabs: ProfileCard.profileTabs,
                        labelColor: Colors.black,
                        indicatorColor: Colors.black,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .015,
                                ),
                                Text(
                                  widget.user.firstname +
                                      " " +
                                      widget.user.lastname,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .005,
                                ),
                                Text(
                                  widget.user.username,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .015,
                                ),
                                buildEmail(),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .015,
                                ),
                                Text(
                                  "POINTS :",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.user.points.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * .015,
                                ),
                                buildRegisterDuration(),
                              ],
                            ),
                            buildFutureBuilderVehiculeInfo()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      widget.user.avatar,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  RichText buildEmail() {
    return RichText(
      text: TextSpan(
        text: widget.user.email,
        style: TextStyle(
          color: Colors.grey[700],
        ),
        children: <WidgetSpan>[
          WidgetSpan(child: SizedBox(width: 5)),
          WidgetSpan(
              child: Icon(Icons.verified, size: 16, color: Colors.green)),
        ],
      ),
    );
  }

  Text buildPointsText(data) {
    return Text(data.scorePoint.toString(),
        style: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ));
  }

  Text buildRegisterDuration() {
    DateTime creation = DateTime.parse(widget.user.createDate);
    Duration diff = DateTime.now().difference(creation);
    int years = (diff.inDays / 365).floor();
    int months = (diff.inDays / 30).floor();
    int days = (diff.inDays / 7).floor();

    String timeAgo;
    if (years > 0) {
      timeAgo = "$years ans";
    } else if (months > 0) {
      timeAgo = "$months mois";
    } else {
      timeAgo = "$days jours";
    }

    return Text(
      "Inscrit(e) il y a $timeAgo",
      style: TextStyle(
        color: Colors.grey[500],
      ),
    );
  }

  FutureBuilder buildFutureBuilderVehiculeInfo() {
    return FutureBuilder(
      future: _getUserVehiculeInfo(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasData) {
              final data = snapshot.data;
              if (data == null) {
                return Center(
                  child: Text(
                    'Nous n\'avons pas réussi a récupérer les données 😵‍💫',
                  ),
                );
              }
              return buildCarInfo(snapshot.data);
            }
            return Text('${snapshot.error}');
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future _getUserVehiculeInfo() async {
    try {
      var token = await storage.read(key: "token");
      Vehicle vehicle =
          await VehicleService.getUserVehicle(token!, widget.user.vehicleId);
      return vehicle;
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
          context,
          "Nous n'avons pas réussi a récupérer vos données.",
          "Veuillez réessayer plus tard.");
    }
  }

  Column buildCarInfo(data) {
    Icon type;
    String usage;
    if (data.type == "CAR") {
      type = Icon(Icons.directions_car);
    } else if (data.type == "MOTO") {
      type = Icon(Icons.directions_bike);
    } else {
      type = Icon(Icons.directions_bus);
    }
    if (data.usage == "INDIVIDUAL") {
      usage = "Personnel";
    } else {
      usage = "Professionnel";
    }

    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
            text: "Type de véhicule : ",
            style: TextStyle(
              color: Colors.black,
            ),
            children: [
              WidgetSpan(child: type),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "Type d'usage : $usage",
        ),
      ],
    );
  }
}
