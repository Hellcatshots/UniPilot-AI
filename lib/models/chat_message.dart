enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final bool isEdgeInference;
  final String? modelName;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.isEdgeInference = false,
    this.modelName,
  });
}
