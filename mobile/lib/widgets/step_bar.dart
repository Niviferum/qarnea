import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Horizontal multi-step progress indicator.
/// [current] is 1-based: pass 1 for the first step, 2 for the second, etc.
class StepBar extends StatelessWidget {
  final int total;
  final int current;

  const StepBar({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 5 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i < current
                  ? QarneaColors.vertCitron
                  : QarneaColors.accentBlanc,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ),
    );
  }
}
