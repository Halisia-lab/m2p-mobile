import 'package:flutter/material.dart';

class Selector extends StatefulWidget {
  final label;
  final childrens;
  final controller;

  const Selector({Key? key, this.label, this.childrens, this.controller})
      : super(key: key);

  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _selectedColor = Colors.black;

  @override
  void initState() {
    _tabController =
        TabController(length: widget.childrens.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Container(
          height: kToolbarHeight - 8.0,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(color: _selectedColor),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: widget.childrens,
            onTap: (value) => {
              widget.controller.text = value.toString(),
            },
          ),
        ),
      ],
    );

    /// Custom Tabbar with solid selected bg and transparent tabbar bg
    // Container(
    //   height: kToolbarHeight + 8.0,
    //   padding:
    //       const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
    //   decoration: BoxDecoration(
    //     color: _selectedColor,
    //     borderRadius: BorderRadius.only(
    //         topLeft: Radius.circular(8.0),
    //         topRight: Radius.circular(8.0)),
    //   ),
    //   child: TabBar(
    //     controller: _tabController,
    //     indicator: BoxDecoration(
    //         borderRadius: BorderRadius.only(
    //             topLeft: Radius.circular(8.0),
    //             topRight: Radius.circular(8.0)),
    //         color: Colors.white),
    //     labelColor: Colors.black,
    //     unselectedLabelColor: Colors.white,
    //     tabs: _tabs,
    //   ),
    // ),

    // /// Custom Tabbar with transparent selected bg and solid selected text
    // TabBar(
    //   controller: _tabController,
    //   tabs: _iconTabs,
    //   unselectedLabelColor: Colors.black,
    //   labelColor: _selectedColor,
    //   indicator: BoxDecoration(
    //     borderRadius: BorderRadius.circular(80.0),
    //     color: _selectedColor.withOpacity(0.2),
    //   ),
    // ),

    // TabBar(
    //   controller: _tabController,
    //   tabs: _tabs,
    //   unselectedLabelColor: Colors.black,
    //   labelColor: _selectedColor,
    //   indicator: BoxDecoration(
    //     borderRadius: BorderRadius.circular(80.0),
    //     color: _selectedColor.withOpacity(0.2),
    //   ),
    // ),
    //       ]
    //           .map((item) => Column(
    //                 /// Added a divider after each item to let the tabbars have room to breathe
    //                 children: [
    //                   item,
    //                   Divider(
    //                     color: Colors.transparent,
    //                   )
    //                 ],
    //               ))
    //           .toList(),
    //     ),
    //   ),
    // );
  }
}
