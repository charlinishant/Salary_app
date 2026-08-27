class ResourceItem {
  ResourceItem(this.raw);
  final Map<String, dynamic> raw;

  String get title => (raw['title'] ?? raw['name'] ?? raw['meetingTitle'] ?? raw['expenseType'] ?? raw['documentType'] ?? raw['month'] ?? 'Record').toString();
  String get subtitle => (raw['message'] ?? raw['status'] ?? raw['date'] ?? raw['createdAt'] ?? '').toString();
}
