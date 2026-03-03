import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../components/animate_in.dart';
import '../../viewmodels/video_view_model.dart';
import '../../data/models/workout_model.dart';

class VideoScreen extends StatefulWidget {
  final Exercise exercise;

  const VideoScreen({super.key, required this.exercise});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoViewModel>().init(widget.exercise);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(children: [
              _buildVideoPlayerPlaceholder(context, viewModel),
              Transform.translate(
                offset: const Offset(0, -24),
                child: _buildVideoDetails(context, viewModel),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayerPlaceholder(BuildContext context, VideoViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (viewModel.isVideoLoading)
              const CircularProgressIndicator(color: Color(0xFF0FA4AF))
            else if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else if (viewModel.youtubeController != null)
              YoutubePlayer(
                controller: viewModel.youtubeController!,
              ),
              
            // Floating back button overlay
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoDetails(BuildContext context, VideoViewModel viewModel) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimateIn(child: Text(viewModel.title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 100), child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
          _buildTag(viewModel.difficulty, const Color(0xFF0FA4AF), const Color(0x190FA4AF)),
          _buildTag('${viewModel.durationMinutes} min', const Color(0xFF964734), const Color(0x19964734)),
          _buildTag('${viewModel.calories} cal', Colors.amber.shade700, Colors.amber.shade50),
        ])),
        const SizedBox(height: 32),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildKeyPoints(viewModel)),
        const SizedBox(height: 32),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildCommonMistakes(viewModel)),
        const SizedBox(height: 80),
      ]),
    );
  }


  Widget _buildTag(String label, Color color, Color bgColor) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)));
  }

  Widget _buildKeyPoints(VideoViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Key Points', style: TextStyle(color: Color(0xFF003135), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...viewModel.keyPoints.asMap().entries.map((e) => _buildPointItem(e.key + 1, e.value)),
    ]);
  }

  Widget _buildPointItem(int index, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF0FA4AF), Color(0xFF024950)])), alignment: Alignment.center, child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 12))),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(color: Color(0xB2024950), fontSize: 14, height: 1.4))),
    ]));
  }

  Widget _buildCommonMistakes(VideoViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Common Mistakes to Avoid', style: TextStyle(color: Color(0xFF003135), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...viewModel.commonMistakes.map((m) => _buildMistakeItem(m)),
    ]);
  }

  Widget _buildMistakeItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0x19964734), borderRadius: BorderRadius.circular(14)),
      child: Row(children: [const Text('⚠️'), const SizedBox(width: 12), Text(text, style: const TextStyle(color: Color(0xFF964734), fontSize: 14))]),
    );
  }
}

