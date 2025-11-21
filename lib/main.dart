import 'package:flutter/material.dart';
import 'package:flowchart_designer/services/openrouter_service.dart';
import 'package:flowchart_designer/widgets/graph_flowchart_viewer.dart';
import 'package:flowchart_designer/widgets/loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flowchart Designer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inputController.clear();
    _errorMessage = null;
    _isLoading = false;

    // Listen to focus changes to hide placeholder
    _focusNode.addListener(() {
      setState(() {}); // Rebuild when focus changes
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _generateFlowchart() async {
    final message = _inputController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    if (_isInvalidRequest(message)) {
      setState(() {
        _errorMessage = 'Invalid request! Try Again';
        _inputController.clear();
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              const LoadingScreen(message: 'Generating flowchart...'),
        ),
      );
    }

    try {
      final flowchartData =
          await OpenRouterService().generateFlowchartJson(message);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                GraphFlowchartViewer(flowchartData: flowchartData),
          ),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _inputController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  bool _isInvalidRequest(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('api') ||
        lowerMessage.contains('http') ||
        lowerMessage.contains('www.') ||
        lowerMessage.contains('.com') ||
        lowerMessage.contains('password') ||
        lowerMessage.contains('token') ||
        lowerMessage.contains('key')) {
      return true;
    }

    final turkishPatterns = ['türk', 'bir', 'için', 'değil', 'şey'];
    for (var pattern in turkishPatterns) {
      if (lowerMessage.contains(pattern)) return true;
    }

    final digitCount = message.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount > 15) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_tree_rounded,
                    size: 40,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Flowify',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI-powered App to Flowchart',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A90E2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4A90E2).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _inputController,
                        focusNode: _focusNode,
                        maxLines: 10,
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(24),
                        ),
                        enabled: !_isLoading,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    if (_inputController.text.isEmpty &&
                        !_isLoading &&
                        !_focusNode.hasFocus)
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: AnimatedTypingPlaceholder(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateFlowchart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Generate Flowchart',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[900],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 60),
                Text(
                  '@ Ahmed Youssef',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedTypingPlaceholder extends StatefulWidget {
  const AnimatedTypingPlaceholder({super.key});

  @override
  State<AnimatedTypingPlaceholder> createState() =>
      _AnimatedTypingPlaceholderState();
}

class _AnimatedTypingPlaceholderState extends State<AnimatedTypingPlaceholder>
    with TickerProviderStateMixin {
  static const String _fullText = 'Ready to turn your idea into a flowchart?';
  String _displayText = '';
  late AnimationController _typingController;
  late AnimationController _cursorController;
  bool _isTypingComplete = false;

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _fullText.length * 50),
    );

    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startTyping();
      }
    });
  }

  void _startTyping() {
    _typingController.addListener(() {
      if (mounted) {
        setState(() {
          final progress = _typingController.value;
          final charCount = (_fullText.length * progress).floor();
          _displayText = _fullText.substring(0, charCount);
        });
      }
    });

    _typingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isTypingComplete = true;
        });
        _cursorController.repeat(reverse: true);
      }
    });

    _typingController.forward();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          fontFamily: 'monospace',
          color: Colors.grey[400],
          height: 1.5,
        ),
        children: [
          TextSpan(text: _displayText),
          if (_isTypingComplete)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: FadeTransition(
                opacity: _cursorController,
                child: Container(
                  width: 2,
                  height: 18,
                  margin: const EdgeInsets.only(left: 2),
                  color: const Color(0xFF4A90E2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
