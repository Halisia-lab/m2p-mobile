import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../common/user_interface_dialog.utils.dart';
import '../main.dart';
import '../models/report.dart';
import '../models/reports.dart';
import '../services/report.dart';

class ReportHistory extends StatefulWidget {
  const ReportHistory({Key? key}) : super(key: key);

  @override
  State<ReportHistory> createState() => _ReportHistoryState();
}

class _ReportHistoryState extends State<ReportHistory> {
  ScrollController _scrollController = ScrollController();
  List<Report> _reports = [];
  int _pageSize = 10;
  int _pageNumber = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadReportHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return buildReportHistoryListView();
  }

  Widget buildReportHistoryListView() {
    if (_reports.isEmpty) {
      return Center(
        child: Text(
          'Vous n\'avez pas encore fait de signalement.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      controller: _scrollController,
      itemCount: _reports.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _reports.length) {
          return buildReportHistoryItem(_reports[index]);
        } else {
          return const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget buildReportHistoryItem(Report report) {
    final createdDateToDateTime = DateTime.parse(report.createdDate);
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
              child: statusIcon(report.status),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${report.associatedParkingPlace.address} '
                  '- ${report.associatedParkingPlace.city}  '
                  '${report.associatedParkingPlace.postalCode}',
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
      case 'CANCELED':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.change_circle, color: Colors.blue);
    }
  }

  Future<void> _loadReportHistoryData() async {
    try {
      var token = await storage.read(key: 'token');
      Reports reports = await ReportService.getUserReports(token!, _pageNumber, _pageSize);
      setState(() {
        _reports.addAll(reports.reports);
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
    await _loadReportHistoryData();
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
