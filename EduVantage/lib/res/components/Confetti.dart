import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final ConfettiController confettiController;

  const ConfettiWidget({Key? key, required this.confettiController, required BlastDirectionality blastDirectionality, required bool shouldLoop, required List<MaterialColor> colors, required Path Function(Size size) createParticlePath}) : super(key: key);

  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConfettiWidget(
        confettiController: widget.confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: true,
        colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
        createParticlePath: drawStar,
      ),
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  void dispose() {
    widget.confettiController.dispose();
    super.dispose();
  }
}
