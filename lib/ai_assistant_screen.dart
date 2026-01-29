import 'package:flutter/material.dart';
import 'main_screen.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                children: [
                  _buildWelcomeMessage(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
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
                MainScreen.switchTab(0); // Switch to Home tab
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0FA4AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Color(0xFFAFDDE5),
                        fontSize: 14,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF0FA4AF), Color(0xFF964734)],
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
           BoxShadow(
            color: Color(0x19000000),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
            offset: Offset(0, 4),
            spreadRadius: -1,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
           Text(
            "Hello! I'm your AI fitness assistant powered by RAG technology. I can help you with personalized diet plans, workout recommendations, and answer any health-related questions based on your profile. How can I assist you today?",
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.62,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '06:53 PM',
            style: TextStyle(
              color: Color(0x7F024950),
              fontSize: 12,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Quick Actions',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0x99024950),
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard('🍎', 'Create Diet Plan')),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('💪', 'Workout Tips')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildActionCard('📊', 'Track Progress')),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard('🍽️', 'Recipe Ideas')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String icon, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF024950),
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFAFDDE5), width: 0.8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0x7FAFDDE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white), // Placeholder icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0x4CAFDDE5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Ask me anything...',
                style: TextStyle(
                  color: Color(0x7F024950),
                  fontSize: 16,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
           Container(
            width: 40,
            height: 40,
             decoration: const BoxDecoration(
              color: Color(0x7FAFDDE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.white), // Placeholder icon
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
             decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF024950), Color(0xFF0FA4AF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                  spreadRadius: -3,
                )
              ],
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}