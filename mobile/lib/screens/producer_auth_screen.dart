import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../widgets/qarnea_text_field.dart';
import '../widgets/step_bar.dart';
import 'login_screen.dart';
import '../models/producer_form_data.dart';
import 'producer_shop_screen.dart';
import '../theme/transitions.dart';

class ProducerAuthScreen extends StatefulWidget {
  const ProducerAuthScreen({super.key});

  @override
  State<ProducerAuthScreen> createState() => _ProducerAuthScreenState();
}

class _ProducerAuthScreenState extends State<ProducerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telephone: _telephoneController.text.trim(),
      );
      if (mounted) {
        final formData = ProducerFormData(
          email: _emailController.text.trim(),
          telephone: _telephoneController.text.trim(),
        );
        Navigator.of(context).push(
          fadeRoute(ProducerShopScreen(formData: formData)),
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: QarneaColors.vertSapin,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(child: StepBar(total: 4, current: 1)),
                ],
              ),
            ),

            // Scrollable form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenH * 0.03),
                      SvgPicture.asset(
                        'assets/images/question_logo_q.svg',
                        height: 32,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Créons ton compte !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'OpenSauceTwo',
                          fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                          fontWeight: FontWeight.w900,
                          color: QarneaColors.vertSapin,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenH * 0.03),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(_errorMessage!,
                              style:
                                  TextStyle(color: Colors.red.shade700)),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: QarneaTextField(
                              controller: _prenomController,
                              placeholder: 'Prénom',
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Requis'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QarneaTextField(
                              controller: _nomController,
                              placeholder: 'Nom',
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Requis'
                                      : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _emailController,
                        placeholder: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Champ requis';
                          }
                          if (!v.contains('@')) return 'E-mail invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _telephoneController,
                        placeholder: 'Téléphone (optionnel)',
                        keyboardType: TextInputType.phone,
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
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Champ requis';
                          if (v.length < 8) return 'Minimum 8 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: QarneaColors.cardBorder,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                fontFamily: 'HostGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                                letterSpacing: -0.32,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: QarneaColors.cardBorder,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google SSO placeholder
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Google SSO non disponible pour l\'instant')),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: QarneaColors.accentBlanc),
                            backgroundColor: QarneaColors.blanc,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.g_mobiledata,
                              size: 26,
                              color: QarneaColors.vertSapin),
                          label: const Text(
                            'Continuer avec Google',
                            style: TextStyle(
                              fontFamily: 'HostGrotesk',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: QarneaColors.vertSapin,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          fadeRoute(const LoginScreen()),
                        ),
                        child: const Text(
                          'J\'ai déjà un compte ! Se connecter !',
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

            // Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                              color: QarneaColors.vertSapin),
                        )
                      : const Text(
                          'Continuer',
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
