import 'package:flutter/material.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../models/rank.dart';
import '../models/ranking.dart';
import '../services/score.dart';

class Ranking extends StatefulWidget {
  const Ranking({Key? key}) : super(key: key);

  static const String routeName = '/ranking';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  List<Rank> _ranks = [];
  int _pageSize = 10;
  int _pageNumber = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadRankingData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text('Classement'),
      ),
      body: buildRankingListView(),
    );
  }

  Widget buildRankingListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      controller: _scrollController,
      itemCount: isLoadingMore ? _ranks.length + 1 : _ranks.length,
      itemBuilder: (context, index) {
        if (index < _ranks.length) {
          return buildRankItem(_ranks[index]);
        } else {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget buildRankItem(Rank rank) {
    final index = _ranks.indexOf(rank);
    return Container(
      height: 90,
      child: Card(
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: index == 0 ? Colors.yellow.shade600 : null,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            title: Text(
              rank.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            trailing: Text(
              '${rank.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadRankingData() async {
    try {
      var token = await storage.read(key: 'token');
      RankingModel ranking =
          await ScoreService.getUsersRanking(token!, _pageNumber, _pageSize);
      setState(() {
        _ranks.addAll(ranking.ranks);
      });
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
        context,
        "Nous n'avons pas pu récupérer le classement actuel.",
        "Veuillez réessayer plus tard.",
      );
    }
  }

  Future<void> _loadMoreData() async {
    if (isLoadingMore) return;
    setState(() {
      isLoadingMore = true;
    });
    _pageNumber++;
    await _loadRankingData();
    setState(() {
      isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (isLoadingMore) return;
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
