import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../widgets/qarnea_text_field.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../theme/transitions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          fadeRoute(const HomeScreen()),
          (_) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Impossible de joindre le serveur');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final bottomPadding = mq.padding.bottom;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: QarneaColors.vertSapin,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenH * 0.03),

                      Text(
                        'Heureux de te revoir !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'OpenSauceTwo',
                          fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                          fontWeight: FontWeight.w900,
                          color: QarneaColors.vertSapin,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: screenH * 0.04),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      QarneaTextField(
                        controller: _emailController,
                        placeholder: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Champ requis';
                          if (!v.contains('@')) return 'E-mail invalide';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _passwordController,
                        placeholder: 'Mot de passe',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: QarneaColors.vertSapin.withAlpha(128),
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Champ requis';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: QarneaColors.vertSapin,
                            letterSpacing: -0.28,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          fadeRoute(const RegisterScreen()),
                        ),
                        child: const Text(
                          'Je n\'ai pas de compte ! Créer !',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: QarneaColors.vertSapin,
                            letterSpacing: -0.28,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: screenH * 0.04),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QarneaColors.vertCitron,
                    foregroundColor: QarneaColors.vertSapin,
                    disabledBackgroundColor:
                        QarneaColors.vertCitron.withAlpha(128),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: QarneaColors.vertSapin,
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.32,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
