import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/neu_button.dart';
import '../../widgets/neu_container.dart';

/// Pure Neumorphic Credits screen acknowledging the original creator Bart Bonte and clone authorship.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuTokens.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeuIconButton(
            icon: Icons.arrow_back_rounded,
            size: 40,
            iconSize: 20,
            iconColor: NeuTokens.textPrimary,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/menu');
              }
            },
          ),
        ),
        title: const Text(
          'Kredit',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: NeuTokens.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: NeuContainer(
              borderRadius: 24,
              style: NeuStyle.convex,
              depth: 8.0,
              blur: 16.0,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Extruded Heart Badge
                  NeuContainer(
                    width: 72,
                    height: 72,
                    shape: BoxShape.circle,
                    style: NeuStyle.convex,
                    depth: 5.0,
                    blur: 10.0,
                    accentColor: NeuTokens.accentAmber,
                    accentGlow: true,
                    child: const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: NeuTokens.accentAmber,
                        size: 36,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Micin, Micin',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: NeuTokens.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Game teka-teki fisika menggambar garis',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: NeuTokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Sunken Attribution Plate
                  NeuContainer(
                    borderRadius: 16,
                    style: NeuStyle.inset,
                    depth: 3.5,
                    blur: 6.0,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Ide & Game Asli (Sugar, Sugar):',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NeuTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bart Bonte',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: NeuTokens.accentAmber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'bontegames.com',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: NeuTokens.textMuted,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: NeuTokens.bevelDark, height: 1),
                        ),
                        const Text(
                          'Pengembang Clone Flutter:',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NeuTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Kayzz Dev',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: NeuTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tactile Neumorphic Back Button
                  NeuButton(
                    width: 180,
                    height: 48,
                    isPill: true,
                    accentColor: NeuTokens.accentAmber,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/menu');
                      }
                    },
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NeuTokens.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
