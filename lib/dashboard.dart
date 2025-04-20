import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';
import 'stats.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // FeelAI Button
                GlassButton(
                  icon: Icons.psychology_alt_rounded,
                  label: "FeelAI",
                  gradient: const LinearGradient(
                    colors: [Color(0xff89f7fe), Color(0xff66a6ff)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                ),
                const SizedBox(height: 26),
                // Stats Button
                GlassButton(
                  icon: Icons.bar_chart_rounded,
                  label: "Stats",
                  gradient: const LinearGradient(
                    colors: [Color(0xfff7971e), Color(0xffff5858)],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsPage()),
                    );
                  },
                ),
                const SizedBox(height: 26),
                // Profile Button
                GlassButton(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  gradient: const LinearGradient(
                    colors: [Color(0xff43e97b), Color(0xff38f9d7)],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Glassmorphic Button Widget
class GlassButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const GlassButton({
    super.key,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.last.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white.withOpacity(0.92)),
            const SizedBox(width: 18),
            Text(
              label,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black26,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
