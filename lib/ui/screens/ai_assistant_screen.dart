import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/ai_assistant_view_model.dart';
import '../../viewmodels/main_view_model.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant_menu': return Icons.restaurant_menu;
      case 'fitness_center': return Icons.fitness_center;
      case 'analytics': return Icons.analytics;
      case 'lightbulb': return Icons.lightbulb;
      case 'swap_horiz': return Icons.swap_horiz;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiAssistantViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.prefillText != null) {
          _messageController.text = viewModel.prefillText!;
          viewModel.clearPrefill();
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    children: [
                      _buildChatThread(context, viewModel),
                      const SizedBox(height: 24),
                      _buildQuickActions(context, viewModel),
                    ],
                  ),
                ),
              ),
              _buildInputArea(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF003135), Color(0xFF024950)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                MainViewModel.switchTabStatic(0);
              }
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Color(0xFF0FA4AF)),
                    SizedBox(width: 8),
                    Text('Online', style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatThread(BuildContext context, AiAssistantViewModel viewModel) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: viewModel.messages.length + (viewModel.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == viewModel.messages.length) {
          return _buildLoadingBubble(context);
        }
        final message = viewModel.messages[index];
        return _buildMessageBubble(context, message);
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context, dynamic message) {
    final bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0FA4AF) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Thinking...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AiAssistantViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Group quick actions in rows of 2 for better layout
          Column(
            children: List.generate((viewModel.quickActions.length / 2).ceil(), (rowIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    for (int i = 0; i < 2; i++)
                      if (rowIndex * 2 + i < viewModel.quickActions.length) ...[
                        Expanded(
                          child: _buildActionCard(
                            context, 
                            _getIconData(viewModel.quickActions[rowIndex * 2 + i].iconName), 
                            viewModel.quickActions[rowIndex * 2 + i].title,
                            () => viewModel.onQuickActionTap(viewModel.quickActions[rowIndex * 2 + i].title)
                          ),
                        ),
                        if (i == 0) const SizedBox(width: 12),
                      ] else 
                        const Spacer(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiAssistantViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  viewModel.sendMessage(_messageController.text.trim());
                  _messageController.clear();
                }
              },
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

