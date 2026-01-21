import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WellnessApp());
}

/* ---------------- CONSTANTS & CONFIGURATION ---------------- */

class AppConstants {
  static const String appName = 'Wellness Reminder';
  static const String apiUrl = 'http://localhost:8080/api/reminder';
  static const Duration reminderInterval = Duration(minutes: 10);
  static const Duration animationDuration = Duration(seconds: 1);
  static const String fallbackMessage = 'Take a deep breath 🌸';
  
  // Colors
  static const Color primaryColor = Color(0xFFB39DDB);
  static const Color backgroundColor = Color(0xFFF6F3FB);
  static const Color cardColor = Colors.white;
  static const Color shadowColor = Colors.black12;
  static const Color iconColor = Color(0xFF9575CD);
  
  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle messageStyle = TextStyle(
    fontSize: 22,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

/* ---------------- FALLBACK MESSAGES SERVICE ---------------- */

class WellnessMessagesService {
  static final List<String> _messages = [
    "Straighten your back 🧍‍♀️",
    "Drink some water 💧",
    "Relax your shoulders",
    "Unclench your jaw",
    "Blink slowly 👀",
    "You're safe. You're calm 🌿",
    "Take 3 deep breaths 😮‍💨",
    "Sit comfortably",
    "Rest your eyes for a moment",
    "You're doing great 💜",
  ];

  static String getRandomMessage() {
    final random = Random();
    return _messages[random.nextInt(_messages.length)];
  }
}

/* ---------------- API SERVICE ---------------- */

class WellnessApiService {
  final http.Client client;
  
  WellnessApiService({http.Client? client}) : client = client ?? http.Client();
  
  Future<String> fetchReminderMessage() async {
    try {
      final response = await client
          .get(Uri.parse(AppConstants.apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message'] ?? AppConstants.fallbackMessage;
      } else {
        throw Exception('Failed to load reminder: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout');
    } on http.ClientException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  void dispose() {
    client.close();
  }
}

/* ---------------- MAIN APP WIDGET ---------------- */

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 14,
            ),
            textStyle: AppConstants.buttonTextStyle,
          ),
        ),
      ),
      home: const WellnessHome(),
    );
  }
}

/* ---------------- HOME SCREEN ---------------- */

class WellnessHome extends StatefulWidget {
  const WellnessHome({super.key});

  @override
  State<WellnessHome> createState() => _WellnessHomeState();
}

class _WellnessHomeState extends State<WellnessHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final WellnessApiService _apiService;
  late Timer _reminderTimer;
  
  String _currentMessage = AppConstants.fallbackMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _startReminderTimer();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  void _initializeServices() {
    _apiService = WellnessApiService();
  }

  void _startReminderTimer() {
    _reminderTimer = Timer.periodic(
      AppConstants.reminderInterval,
      (_) => _fetchAndUpdateReminder(),
    );
  }

  Future<void> _fetchAndUpdateReminder() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final message = await _apiService.fetchReminderMessage();
      await _updateMessageWithAnimation(message);
    } catch (e) {
      _showFallbackMessage();
      debugPrint('Error fetching reminder: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateMessageWithAnimation(String message) async {
    await _animationController.reverse();
    
    setState(() {
      _currentMessage = message;
    });
    
    await _animationController.forward();
  }

  void _showFallbackMessage() {
    final randomMessage = WellnessMessagesService.getRandomMessage();
    _updateMessageWithAnimation(randomMessage);
  }

  void _handleManualReminder() async {
    if (_isLoading) return;
    await _fetchAndUpdateReminder();
    
    // Show snackbar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New reminder fetched!'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _reminderTimer.cancel();
    _animationController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Wellness Reminder 🌷',
          style: AppConstants.titleStyle,
        ),
      ),
      body: Center(
        child: _buildMainContent(),
      ),
      floatingActionButton: _buildRefreshButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMainContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildReminderCard(),
      ),
    );
  }

  Widget _buildReminderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      color: AppConstants.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildMessageText(),
            const SizedBox(height: 32),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.self_improvement,
      size: 80,
      color: AppConstants.iconColor,
    );
  }

  Widget _buildMessageText() {
    return Text(
      _currentMessage,
      textAlign: TextAlign.center,
      style: AppConstants.messageStyle,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleManualReminder,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh, size: 20),
      label: Text(_isLoading ? 'Loading...' : 'Remind Me 🌼'),
    );
  }

  Widget _buildRefreshButton() {
    return FloatingActionButton.small(
      onPressed: _handleManualReminder,
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      tooltip: 'Get new reminder',
      child: const Icon(Icons.auto_awesome),
    );
  }
}