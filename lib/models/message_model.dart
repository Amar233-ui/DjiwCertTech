class MessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}