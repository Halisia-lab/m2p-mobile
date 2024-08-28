import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../models/search.dart';
import '../models/searches.dart';
import '../services/search.dart';

class SearchHistory extends StatefulWidget {
  const SearchHistory({Key? key}) : super(key: key);

  @override
  State<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  ScrollController _scrollController = ScrollController();
  List<Search> _searches = [];
  int _pageSize = 10;
  int _pageNumber = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadSearchHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return buildSearchHistoryListView();
  }

  Widget buildSearchHistoryListView() {
    if (_searches.isEmpty) {
      return Center(
        child: Text(
          'Vous n\'avez pas encore faire de recherche.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      controller: _scrollController,
      itemCount: _searches.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _searches.length) {
          return buildSearchHistoryItem(_searches[index]);
        } else {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget buildSearchHistoryItem(Search search) {
    final createdDateToDateTime = DateTime.parse(search.createdDate);
    final formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(createdDateToDateTime);

    return Container(
      height: 90,
      child: Card(
        child: Center(
          child: ListTile(
            leading: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.1,
              child: statusIcon(search.status),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                search.status == 'ABANDONED'
                    ? Text(
                        '${search.associatedReport.associatedParkingPlace.address}'
                        ' - ${search.associatedReport.associatedParkingPlace.city}'
                        ' ${search.associatedReport.associatedParkingPlace.postalCode}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        '${search.associatedReport.associatedParkingPlace.address}'
                        ' - ${search.associatedReport.associatedParkingPlace.city}'
                        ' ${search.associatedReport.associatedParkingPlace.postalCode}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon statusIcon(String status) {
    switch (status) {
      case 'SUCCESSFUL':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'FAILED':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'PENDING':
        return const Icon(Icons.change_circle, color: Colors.blue);
      default:
        return const Icon(Icons.error, color: Colors.red);
    }
  }

  Future<void> _loadSearchHistoryData() async {
    try {
      var token = await storage.read(key: 'token');
      Searches searches =
          await SearchService.getUserSearches(token!, _pageNumber, _pageSize);
      setState(() {
        _searches.addAll(searches.searches);
      });
    } catch (err) {
      UserInterfaceDialog.displayAlertDialog(
        context,
        "Nous n'avons pas pu charger votre historique.",
        "Veuillez réessayer plus tard.",
      );
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    _pageNumber++;
    await _loadSearchHistoryData();
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
