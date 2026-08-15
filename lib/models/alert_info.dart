enum AlertType { delay, traffic, diverted, cancelled, arrivingSoon }

class AlertInfo {
  final String title;
  final String message;
  final AlertType type;
  final String timestamp;

  const AlertInfo({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
  });
}
