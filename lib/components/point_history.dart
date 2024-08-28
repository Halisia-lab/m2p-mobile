import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../models/score.dart';
import '../models/scores.dart';
import '../services/score.dart';

class PointHistory extends StatefulWidget {
  const PointHistory({Key? key}) : super(key: key);

  @override
  State<PointHistory> createState() => _PointHistoryState();
}

class _PointHistoryState extends State<PointHistory> {
  ScrollController _scrollController = ScrollController();
  List<Score> _points = [];
  int _pageSize = 10;
  int _pageNumber = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadPointHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return buildPointHistoryListView();
  }

  Widget buildPointHistoryListView() {
    if (_points.isEmpty) {
      return Center(
        child: Text(
          'Vous n\'avez pas encore de points.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      controller: _scrollController,
      itemCount: _points.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _points.length) {
          return buildPointHistoryItem(_points[index]);
        } else {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget buildPointHistoryItem(Score point) {
    final createdDateToDateTime = DateTime.parse(point.createdDate);
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(createdDateToDateTime);

    return Container(
      height: 90,
      child: Card(
        child: Center(
          child: ListTile(
            leading: Container(
              alignment: Alignment.center,
              width: 100,
              child: Text(formattedDate),
            ),
            title: point.status == 'CANCELED'
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Canceled',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(''),
            trailing: point.status == 'canceled'
                ? Text(
                    '+ ' + point.earnedPoints.toString(),
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                    ),
                  )
                : Text(
                    '+ ' + point.earnedPoints.toString(),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadPointHistoryData() async {
    try {
      var token = await storage.read(key: 'token');
      Scores scores =
          await ScoreService.getUserScore(token!, _pageSize, _pageNumber);
      setState(() {
        _points.addAll(scores.scores);
      });
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
        context,
        'Nous n\'avons pas pu charger votre historique.',
        'Veuillez réessayer plus tard.',
      );
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _pageNumber++;
    await _loadPointHistoryData();
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
