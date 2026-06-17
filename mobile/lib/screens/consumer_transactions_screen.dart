import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../widgets/qarnea_text_field.dart';
import '../widgets/step_bar.dart';
import 'welcome_screen.dart';
import '../theme/transitions.dart';

class ConsumerTransactionsScreen extends StatefulWidget {
  const ConsumerTransactionsScreen({super.key});

  @override
  State<ConsumerTransactionsScreen> createState() =>
      _ConsumerTransactionsScreenState();
}

class _ConsumerTransactionsScreenState
    extends State<ConsumerTransactionsScreen> {
  final _adresseController = TextEditingController();
  final _relaisController = TextEditingController();

  bool _carteEnabled = true;
  bool _paypalEnabled = false;
  bool _applePayEnabled = false;

  @override
  void dispose() {
    _adresseController.dispose();
    _relaisController.dispose();
    super.dispose();
  }

  void _goToWelcome() {
    Navigator.of(context).push(
      fadeRoute(const WelcomeScreen()),
    );
  }

  void _notAvailableYet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bientôt disponible')),
    );
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
                  const Expanded(child: StepBar(total: 2, current: 2)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _goToWelcome,
                    child: const Text(
                      'Passer',
                      style: TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: QarneaColors.vertSapin,
                        letterSpacing: -0.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      'Pour faciliter les transactions !',
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

                    QarneaTextField(
                      controller: _adresseController,
                      placeholder: 'Adresse de livraison complète',
                    ),
                    const SizedBox(height: 16),

                    QarneaTextField(
                      controller: _relaisController,
                      placeholder: 'Point relais favori',
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                      decoration: BoxDecoration(
                        color: QarneaColors.blanc,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: QarneaColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Moyen de paiement',
                            style: TextStyle(
                              fontFamily: 'OpenSauceTwo',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: QarneaColors.vertSapin,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Carte Bancaire',
                                style: TextStyle(
                                  fontFamily: 'HostGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: QarneaColors.vertSapin,
                                  letterSpacing: -0.32,
                                ),
                              ),
                              _PillToggle(
                                value: _carteEnabled,
                                onChanged: (v) =>
                                    setState(() => _carteEnabled = v),
                              ),
                            ],
                          ),
                          if (_carteEnabled) ...[
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _notAvailableYet,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Numéro de carte',
                                    style: TextStyle(
                                      fontFamily: 'HostGrotesk',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: QarneaColors.vertSapin,
                                      letterSpacing: -0.28,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '1234 1234 1234 1234',
                                        style: TextStyle(
                                          fontFamily: 'HostGrotesk',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          color: QarneaColors.vertSapin
                                              .withAlpha(51),
                                          letterSpacing: -0.28,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        size: 18,
                                        color: QarneaColors.cardBorder,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: QarneaColors.accentBlanc),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Paypal',
                                style: TextStyle(
                                  fontFamily: 'HostGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: QarneaColors.vertSapin,
                                  letterSpacing: -0.32,
                                ),
                              ),
                              _PillToggle(
                                value: _paypalEnabled,
                                onChanged: (v) =>
                                    setState(() => _paypalEnabled = v),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: QarneaColors.accentBlanc),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Apple Pay',
                                style: TextStyle(
                                  fontFamily: 'HostGrotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  color: QarneaColors.vertSapin,
                                  letterSpacing: -0.32,
                                ),
                              ),
                              _PillToggle(
                                value: _applePayEnabled,
                                onChanged: (v) =>
                                    setState(() => _applePayEnabled = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToWelcome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QarneaColors.vertCitron,
                    foregroundColor: QarneaColors.vertSapin,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
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

/// Pill-shaped on/off switch matching the Figma "Active/Désactive" component.
class _PillToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 25,
        padding: EdgeInsets.only(
          left: value ? 30 : 6,
          right: value ? 6 : 30,
          top: 5,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: value ? QarneaColors.vertCitron : QarneaColors.cardBorder,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 20,
          height: 15,
          decoration: BoxDecoration(
            color: QarneaColors.blanc,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
