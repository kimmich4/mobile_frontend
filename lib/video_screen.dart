import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVideoPlayerPlaceholder(context),
            Transform.translate(
              offset: const Offset(0, -24),
              child: _buildVideoDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.black,
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF003135), Color(0xFF024950)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 64,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
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
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Push-ups Tutorial',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag('Beginner', const Color(0xFF0FA4AF), const Color(0x190FA4AF)),
              const SizedBox(width: 12),
              _buildTag('10 min', const Color(0xFF964734), const Color(0x19964734)),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'About this exercise',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 12),
          // AR Posture Guide Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0x4CAFDDE5),
               borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: const [
                 Icon(Icons.view_in_ar, color: Color(0xFF024950)),
                 SizedBox(width: 8),
                 Text(
                   'Enable AR Posture Guide',
                   style: TextStyle(
                     color: Color(0xFF024950),
                     fontSize: 16,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ],
            ),
          ),
          const SizedBox(height: 24),
          _buildKeyPoints(),
           const SizedBox(height: 24),
          _buildCommonMistakes(),
           const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildKeyPoints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Points',
          style: TextStyle(
            color: Color(0xFF003135),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPointItem(1, 'Keep your core engaged throughout the movement'),
        _buildPointItem(2, 'Maintain proper breathing pattern'),
        _buildPointItem(3, 'Focus on controlled, smooth movements'),
        _buildPointItem(4, 'Stop if you feel any pain or discomfort'),
      ],
    );
  }

  Widget _buildPointItem(int index, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                 colors: [Color(0xFF0FA4AF), Color(0xFF024950)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xB2024950),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonMistakes() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Common Mistakes to Avoid',
          style: TextStyle(
            color: Color(0xFF003135),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildMistakeItem('Arching your back excessively'),
        _buildMistakeItem('Holding your breath'),
        _buildMistakeItem('Moving too quickly'),
      ],
    );
  }

  Widget _buildMistakeItem(String text) {
     return Container(
       margin: const EdgeInsets.only(bottom: 8),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: const Color(0x19964734),
         borderRadius: BorderRadius.circular(14),
       ),
       child: Row(
         children: [
           const Text(
             '⚠️',
             style: TextStyle(fontSize: 16),
           ),
           const SizedBox(width: 12),
           Text(
             text,
             style: const TextStyle(
               color: Color(0xFF964734),
               fontSize: 14,
             ),
           ),
         ],
       ),
     );
  }
}