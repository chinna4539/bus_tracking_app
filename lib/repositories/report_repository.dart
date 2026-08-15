import '../services/firestore_service.dart';

class ReportRepository {
  final FirestoreService _service;

  ReportRepository({FirestoreService? service})
      : _service = service ?? FirestoreService();

  Future<void> submitReport(Map<String, dynamic> report) async {
    await _service.reportsRef.add({
      ...report,
      'status': 'open',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
