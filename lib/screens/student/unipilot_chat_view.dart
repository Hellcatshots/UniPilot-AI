import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import '../../services/university_repository.dart';
import '../../services/hybrid_ai_service.dart';
import '../../models/chat_message.dart';
import '../../data/prompt_templates.dart';
import '../../theme/app_theme.dart';

class UnipilotChatView extends StatefulWidget {
  const UnipilotChatView({super.key});

  @override
  State<UnipilotChatView> createState() => _UnipilotChatViewState();
}

class _UnipilotChatViewState extends State<UnipilotChatView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isStreaming = false;
  StreamSubscription<String>? _sub;

  final List<String> _quickPrompts = [
    'Can I get a prerequisite waiver for PMT670?',
    'How do I balance a heavy finance elective with product design?',
    'What are the eligibility rules for the Dean’s Conference Grant?',
    'Which electives give the highest edge for VC associate roles?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        id: 'msg_0',
        sender: MessageSender.assistant,
        text: 'Hello! I am **UniPilot AI**, your 24/7 University Academic & Logistics Concierge. Ask me anything about course prerequisites, timetable clashes, professor office hours, or career trajectories.',
        timestamp: DateTime.now(),
        isEdgeInference: false,
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    final query = text.trim();
    if (query.isEmpty || _isStreaming) return;
    _inputController.clear();

    final repo = context.read<UniversityRepository>();
    final aiService = context.read<HybridAiService>();

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: query,
      timestamp: DateTime.now(),
    );

    final assistantMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
      sender: MessageSender.assistant,
      text: '',
      timestamp: DateTime.now(),
      isEdgeInference: aiService.isEdgeOffline,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(assistantMsg);
      _isStreaming = true;
    });
    _scrollToBottom();

    final studentContext = '''
Student: ${repo.activeStudent.name} (${repo.activeStudent.program})
Current Term: ${repo.activeStudent.currentTerm} | GPA: ${repo.activeStudent.currentGpa}
Career Goal: ${repo.activeStudent.careerAmbition}
Completed Courses: ${repo.activeStudent.completedCourseCodes.join(', ')}
Enrolled Electives: ${repo.selectedCourses.map((c) => "${c.code} (${c.name})").join(', ')}
''';

    final prompt = PromptTemplates.buildConciergeChatPrompt(
      studentContext: studentContext,
      question: query,
    );

    _sub?.cancel();
    _sub = aiService
        .generateStream(
          systemPrompt: PromptTemplates.systemBasePrompt,
          userPrompt: prompt,
          maxTokens: 1800,
        )
        .listen(
          (chunk) {
            setState(() {
              final last = _messages.last;
              _messages[_messages.length - 1] = ChatMessage(
                id: last.id,
                sender: last.sender,
                text: last.text + chunk,
                timestamp: last.timestamp,
                isEdgeInference: last.isEdgeInference,
              );
            });
            _scrollToBottom();
          },
          onDone: () => setState(() => _isStreaming = false),
          onError: (e) {
            setState(() {
              final last = _messages.last;
              _messages[_messages.length - 1] = ChatMessage(
                id: last.id,
                sender: last.sender,
                text: '${last.text}\n\n*(Error: $e)*',
                timestamp: last.timestamp,
                isEdgeInference: last.isEdgeInference,
              );
              _isStreaming = false;
            });
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick Prompt Pills
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.cardSurface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickPrompts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(p, style: const TextStyle(fontSize: 11, color: AppTheme.violetLight)),
                    backgroundColor: AppTheme.primaryViolet.withValues(alpha: 0.15),
                    side: BorderSide(color: AppTheme.primaryViolet.withValues(alpha: 0.3)),
                    onPressed: () => _sendMessage(p),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Chat Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final msg = _messages[idx];
              final isUser = msg.sender == MessageSender.user;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryViolet.withValues(alpha: 0.3) : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUser ? AppTheme.primaryViolet.withValues(alpha: 0.6) : AppTheme.borderColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
                            size: 14,
                            color: isUser ? AppTheme.violetLight : AppTheme.neonCyan,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUser ? 'You' : 'UniPilot AI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isUser ? AppTheme.violetLight : AppTheme.neonCyan,
                            ),
                          ),
                          if (!isUser && msg.isEdgeInference) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('⚡ Edge Offline', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      GptMarkdown(
                        msg.text.isEmpty && _isStreaming ? 'Thinking...' : msg.text,
                        style: const TextStyle(fontSize: 13.5, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Input Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F1524),
            border: Border(top: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask UniPilot anything about courses, faculty, graduation credits, or logistics...',
                    filled: true,
                    fillColor: AppTheme.cardSurface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isStreaming ? null : () => _sendMessage(_inputController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryViolet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isStreaming
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
