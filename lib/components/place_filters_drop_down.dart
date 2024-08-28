import 'package:flutter/material.dart';
import 'package:m2p/models/place_filters.dart';
import 'package:m2p/services/map.dart';

import '../services/place.dart';

class PlaceFiltersDropDown extends StatefulWidget {
  List<DropdownMenuItem<String>> items;
  PlaceFilters placeFiltersType;

  PlaceFiltersDropDown(
      {required this.items, required this.placeFiltersType, super.key});

  @override
  State<PlaceFiltersDropDown> createState() => _PlaceFiltersDropDownState();
}

class _PlaceFiltersDropDownState extends State<PlaceFiltersDropDown> {
  String dropdownValue = "TOUTES";

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      onChanged: (String? value) {
        PlaceService().addFilter(widget.placeFiltersType, value ?? "TOUTES");
        setState(() {
          dropdownValue = value!;
        });
      },
      items: widget.items,
    );
  }
}
