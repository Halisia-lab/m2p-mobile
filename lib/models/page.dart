class Page {
  final int pageSize;
  final int pageNumber;

  Page({
    required this.pageSize,
    required this.pageNumber,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    int pageSize = json["pageSize"];
    int pageNumber = json["pageNumber"];

    return Page(
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
  }

  @override
  String toString() {
    return 'Page{pageSize: $pageSize, pageNumber: $pageNumber}';
  }
}