import 'package:flutter/material.dart';
import '../../../data/repositories/idea_repository.dart';
import '../../../data/services/speech_service.dart';
import '../../theme/app_theme.dart';
import '../analysis/analysis_loading_screen.dart';

class IdeaEntryScreen extends StatefulWidget {
  final IdeaRepository repository;

  const IdeaEntryScreen({super.key, required this.repository});

  @override
  State<IdeaEntryScreen> createState() => _IdeaEntryScreenState();
}

class _IdeaEntryScreenState extends State<IdeaEntryScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  final SpeechService _speechService = SpeechService();
  
  bool _isListening = false;
  double _soundLevel = 0.0;
  late AnimationController _pulseController;

  final List<String> _suggestions = [
    'An AI expense tracker that works completely offline using voice input.',
    'A SaaS that generates micro-marketing copy and publishes to social media.',
    'A mobile app to learn coding through bite-sized interactive quizzes.',
    'A self-hosted privacy-focused calendar that syncs files using WebDAV.',
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    _initSpeech();

    // Pulse animation for mic button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  void _initSpeech() async {
    await _speechService.initSpeech();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Re-build to enable/disable button
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      _pulseController.stop();
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    } else {
      setState(() {
        _isListening = true;
      });
      _pulseController.repeat(reverse: true);
      
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _textController.text = text;
          });
        },
        onSoundLevelChanged: (level) {
          setState(() {
            _soundLevel = level;
          });
        },
      );
    }
  }

  void _validateIdea() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Navigate to loading/validation execution screen
    final validated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisLoadingScreen(
          ideaText: text,
          repository: widget.repository,
        ),
      ),
    );

    if (validated == true && mounted) {
      Navigator.pop(context, true); // Return to dashboard, reloading history
    }
  }

  @override
  Widget build(BuildContext context) {
    final textEmpty = _textController.text.trim().isEmpty;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryTextColor),
                      ),
                      const Text(
                        'Submit Startup Idea',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'DESCRIBE YOUR STARTUP CONCEPT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Idea Input Field
                  Container(
                    decoration: AppTheme.glassBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _textController,
                          maxLines: 8,
                          maxLength: 500,
                          style: const TextStyle(color: AppTheme.primaryTextColor, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Type your business concept here...\n\nExample: "I want to build a platform that automates rental agreement creation using AI, serving property managers."',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                            counterStyle: TextStyle(color: AppTheme.secondaryTextColor),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Microphone trigger
                            GestureDetector(
                              onTap: _toggleListening,
                              child: Row(
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      double scale = 1.0 + (_pulseController.value * 0.15 * (_soundLevel / 10).clamp(0.0, 1.0));
                                      return Transform.scale(
                                        scale: _isListening ? scale : 1.0,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: _isListening 
                                                ? AppTheme.accentColor.withOpacity(0.2) 
                                                : Colors.black.withOpacity(0.04),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _isListening ? AppTheme.accentColor : Colors.black12,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            _isListening ? Icons.mic : Icons.mic_none,
                                            color: _isListening ? AppTheme.accentColor : AppTheme.secondaryTextColor,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isListening ? 'Listening (Tap to stop)...' : 'Record voice idea',
                                    style: TextStyle(
                                      color: _isListening ? AppTheme.accentColor : AppTheme.secondaryTextColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_textController.text.isNotEmpty)
                              IconButton(
                                onPressed: () => _textController.clear(),
                                icon: const Icon(Icons.clear, color: Colors.grey),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Suggestions List
                  const Text(
                    'POPULAR SUGGESTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _textController.text = suggestion;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppTheme.secondaryColor, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 40),

                  // Action Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: textEmpty ? null : _validateIdea,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.black.withOpacity(0.05),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: textEmpty ? null : AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Analyze Idea with Gemini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textEmpty ? Colors.grey[500] : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
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
