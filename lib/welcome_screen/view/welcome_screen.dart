import 'package:amie_welcome_screen/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: ReactionsOverlay(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Background(),
            Foreground(),
          ],
        ),
      ),
    );
  }
}
