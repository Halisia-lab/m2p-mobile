import 'package:flutter/material.dart';

class MapActionButtons extends StatelessWidget {
  final Function onReportButtonTap;
  final Function moveToCurrentLocation;
  const MapActionButtons(
      {required this.onReportButtonTap,
      required this.moveToCurrentLocation,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'report',
            backgroundColor: Colors.black,
            child: Icon(
              Icons.local_parking,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () async => onReportButtonTap(),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
          ),
          FloatingActionButton(
            heroTag: 'currentLocation',
            backgroundColor: Colors.white,
            child: Icon(
              Icons.gps_fixed,
              color: Colors.grey,
            ),
            onPressed: () async => moveToCurrentLocation(),
          ),
        ],
      ),
    );
  }
}
