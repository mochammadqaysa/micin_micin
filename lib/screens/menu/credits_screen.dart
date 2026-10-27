import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_ui/pixel_ui.dart';
import '../../core/pixel_terrain_tokens.dart';

/// 16-bit Pixel Zen Credits screen acknowledging original creator Bart Bonte and clone authorship.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelTerrainTokens.slate,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PixelButton(
            logicalWidth: 10,
            logicalHeight: 10,
            width: 40,
            height: 40,
            normalStyle: PixelTerrainTokens.pauseButtonNormal,
            pressedStyle: PixelTerrainTokens.pauseButtonPressed,
            pressChildOffset: const Offset(0, 1),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/menu');
              }
            },
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'KREDIT',
          style: PixelText.mulmaru(
            fontSize: 20,
            color: PixelTerrainTokens.sand,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: PixelBox(
              logicalWidth: 70,
              logicalHeight: 100,
              style: PixelTerrainTokens.tealBoxStyle,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pixel Heart Badge
                    PixelBox(
                      logicalWidth: 14,
                      logicalHeight: 14,
                      width: 56,
                      height: 56,
                      style: PixelTerrainTokens.mossBoxStyle,
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          color: PixelTerrainTokens.sand,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'MICIN, MICIN',
                      style: PixelText.mulmaru(
                        fontSize: 22,
                        color: PixelTerrainTokens.sand,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Game teka-teki fisika garis & butiran',
                      style: PixelText.mulmaru(
                        fontSize: 11,
                        color: PixelTerrainTokens.sage.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Attribution Plate
                    PixelBox(
                      logicalWidth: 60,
                      logicalHeight: 40,
                      style: PixelTerrainTokens.slateBoxStyle,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Ide & Game Asli (Sugar, Sugar):',
                              style: PixelText.mulmaru(
                                fontSize: 10,
                                color: PixelTerrainTokens.sage.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bart Bonte',
                              style: PixelText.mulmaru(
                                fontSize: 16,
                                color: PixelTerrainTokens.sand,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'bontegames.com',
                              style: PixelText.mulmaru(
                                fontSize: 10,
                                color: PixelTerrainTokens.sage.withValues(alpha: 0.6),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Divider(
                                color: PixelTerrainTokens.sage,
                                height: 1,
                              ),
                            ),
                            Text(
                              'Pengembang Clone Flutter:',
                              style: PixelText.mulmaru(
                                fontSize: 10,
                                color: PixelTerrainTokens.sage.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kayzz Dev',
                              style: PixelText.mulmaru(
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tactile Back Button
                    PixelButton(
                      logicalWidth: 40,
                      logicalHeight: 11,
                      width: 160,
                      height: 44,
                      normalStyle: PixelTerrainTokens.actionButtonNormal,
                      pressedStyle: PixelTerrainTokens.actionButtonPressed,
                      pressChildOffset: const Offset(0, 1),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/menu');
                        }
                      },
                      child: Center(
                        child: Text(
                          'KEMBALI',
                          style: PixelText.mulmaru(
                            fontSize: 13,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
