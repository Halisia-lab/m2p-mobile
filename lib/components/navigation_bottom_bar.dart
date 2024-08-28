import 'package:flutter/material.dart';

import '../services/map.dart';

class NavigationBottomBar extends StatelessWidget {
  final Function endNavigationMode;
  final polylineCoordinates;

  final double distanceLeft;
  NavigationBottomBar(
      {required this.endNavigationMode,
      required this.polylineCoordinates,
      required this.distanceLeft,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height: 80,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                  future: MapService.getPreciseDistanceBetweenTwoPoints(
                      polylineCoordinates),
                  builder: (context, distance) {
                    if (distance.data == null) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.red),
                        Text(
                          "${distanceLeft.toStringAsFixed(2)} km",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    );
                  },),
              FilledButton(
                  onPressed: () => endNavigationMode(),
                  child: Text(
                    "Terminer",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),)
            ],
          ),
        ),
      ),
    );
  }
}
