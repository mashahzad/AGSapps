import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ==========================================
// 2. LOGIN SCREEN
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAccepted = false;
  late TapGestureRecognizer _termsGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _termsGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        if (mounted) {
          _showTermsDialog(context);
        }
      };
  }

  @override
  void dispose() {
    _termsGestureRecognizer.dispose();
    super.dispose();
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "Welcome to Kids Growth Journal!\n\n"
                  "1. Privacy First: All growth records, photos, and personal notes are kept strictly private.\n\n"
                  "2. Data Responsibility: Users are responsible for maintaining backups of their records.\n\n"
                  "3. Content Usage: AI advice is for general informational purposes only.",
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showOurStoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Our App",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "Welcome to Kids Growth Journal!\n\n"
                  "Created with love by the AGS team, this app helps parents track, preserve, "
                  "and cherish every precious milestone in their children's growth and daily family life.\n\n"
                  "Thank you for letting us be part of your family's journey!",
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Let's Begin"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade100),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Parent Child Records App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAccepted,
                        activeColor: Colors.indigo,
                        onChanged: (bool? value) {
                          setState(() {
                            _isAccepted = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I accept the ",
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: "Terms and Conditions",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _termsGestureRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: _isAccepted
                        ? () => Navigator.pushReplacementNamed(context, '/family')
                        : null,
                    child: const Text(
                      "Start Recording Your Memories",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      backgroundColor: Colors.white.withOpacity(0.9),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isAccepted
                        ? () {
                      // Tries named route '/our_story', otherwise shows description dialog
                      try {
                        Navigator.pushNamed(context, '/description');
                      } catch (_) {
                        _showOurStoryDialog(context);
                      }
                    }
                        : null,
                    child: const Text(
                      "Know more about this App",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "Made by AGS team",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
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