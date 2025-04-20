import 'package:flutter/material.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'dashboard.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return Scaffold(
      backgroundColor: Colors.black12,
      body: PageView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        children: [
          // Welcome Page
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Centered Image
                Image.asset(
                  'assets/images/open.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                // Animated Gradient Text
                GradientAnimationText(
                  text: const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  colors: const [
                    Colors.white,
                    // Colors.indigo,
                    Colors.blue,
                    Colors.red,
                  ],
                  duration: const Duration(seconds: 3),
                  reverse: true,
                ),
                const SizedBox(height: 30),
                // Swipe hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.swipe_left, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      "Swipe to continue",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dashboard Page
          const DashboardPage(),
        ],
      ),
    );
  }
}
