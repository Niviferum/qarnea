import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import '../theme/transitions.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        fadeRoute(const RoleSelectionScreen()),
      );
    });
    return const SizedBox.shrink();
  }
}
