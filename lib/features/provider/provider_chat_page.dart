import 'package:flutter/material.dart';

import '../../mock/mock_data.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/widgets/feedback/app_error_state.dart';
import '../../shared/widgets/navigation/app_back_button.dart';

/// Discussion du prestataire sur la conversation partagée avec le client.
class ProviderChatPage extends StatefulWidget {
  const ProviderChatPage({super.key, required this.conversationId});
  final String? conversationId;

  @override
  State<ProviderChatPage> createState() => _ProviderChatPageState();
}

class _ProviderChatPageState extends State<ProviderChatPage> {
  final _input = TextEditingController();
  MockConversation? get _conversation {
    for (final value in MockData.conversations) {
      if (value.id == widget.conversationId &&
          value.providerId == MockData.providerDashboardProfile.providerId) {
        return value;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final conversation = _conversation;
    final text = _input.text.trim();
    if (conversation == null || text.isEmpty) return;
    MockData.addMessageToConversation(
      conversation: conversation,
      text: text,
      isFromClient: false,
    );
    setState(_input.clear);
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation;
    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: AppErrorState(
          title: 'Conversation introuvable',
          message:
              'Cette conversation ne correspond pas au prestataire de démonstration.',
          retryLabel: 'Retour',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    final profile = MockData.providerDashboardProfile;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client de démonstration', style: AppTextStyles.label),
            Text(profile.profession, style: AppTextStyles.small),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: AppColors.lightGreen,
            child: Text(
              'Conversation locale : aucun message n’est transmis à un utilisateur réel.',
              textAlign: TextAlign.center,
              style: AppTextStyles.small.copyWith(color: AppColors.primary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: ValueKey(conversation.messages.length),
              padding: const EdgeInsets.all(16),
              itemCount: conversation.messages.length,
              itemBuilder: (context, index) {
                final message = conversation.messages[index];
                return Align(
                  alignment: message.isFromClient
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .78,
                    ),
                    decoration: BoxDecoration(
                      color: message.isFromClient
                          ? AppColors.white
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message.text,
                          style: AppTextStyles.body.copyWith(
                            color: message.isFromClient
                                ? AppColors.textPrimary
                                : AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.small.copyWith(
                            color: message.isFromClient
                                ? AppColors.textSecondary
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message…',
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
