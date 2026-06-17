import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/producer_form_data.dart';
import '../services/producteur_service.dart';
import '../widgets/qarnea_text_field.dart';
import '../widgets/step_bar.dart';
import 'producer_verification_screen.dart';
import '../theme/transitions.dart';

class ProducerLogisticsScreen extends StatefulWidget {
  final ProducerFormData formData;
  const ProducerLogisticsScreen({super.key, required this.formData});

  @override
  State<ProducerLogisticsScreen> createState() =>
      _ProducerLogisticsScreenState();
}

class _ProducerLogisticsScreenState
    extends State<ProducerLogisticsScreen> {
  // Paiement
  bool _virementEnabled = false;
  bool _paypalEnabled = false;
  final _ibanController = TextEditingController();

  // Livraison
  bool _colissimo = false;
  bool _mondialRelay = false;
  bool _retraitFerme = true;
  final _delaisController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _ibanController.dispose();
    _delaisController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    widget.formData
      ..venteDirecte = _retraitFerme
      ..ventePaniers = false
      ..livraisonPossible = _colissimo || _mondialRelay;

    try {
      await ProducteurService().soumettre(widget.formData);
      if (mounted) {
        Navigator.of(context).push(
          fadeRoute(const ProducerVerificationScreen()),
        );
      }
    } on ProducteurException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Impossible de joindre le serveur');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'OpenSauceTwo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: QarneaColors.vertSapin,
          ),
        ),
      );

  Widget _toggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: QarneaColors.vertSapin,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: QarneaColors.vertCitron,
        activeTrackColor: QarneaColors.vertCitron.withAlpha(128),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      ),
    );
  }

  Widget _checkboxRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: QarneaColors.blanc,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: QarneaColors.accentBlanc),
      ),
      child: CheckboxListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: QarneaColors.vertSapin,
          ),
        ),
        value: value,
        onChanged: onChanged,
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? QarneaColors.vertCitron
                : QarneaColors.accentBlanc),
        checkColor: QarneaColors.vertSapin,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
        controlAffinity: ListTileControlAffinity.trailing,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
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
                  const Expanded(child: StepBar(total: 4, current: 4)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenH * 0.03),
                    Text(
                      'Logistique et paiement',
                      style: TextStyle(
                        fontFamily: 'OpenSauceTwo',
                        fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                        fontWeight: FontWeight.w900,
                        color: QarneaColors.vertSapin,
                      ),
                    ),

                    _sectionTitle('Modes de paiement'),
                    _toggleRow('Virement bancaire', _virementEnabled,
                        (v) => setState(() => _virementEnabled = v)),
                    if (_virementEnabled) ...[
                      const SizedBox(height: 4),
                      QarneaTextField(
                        controller: _ibanController,
                        placeholder: 'IBAN (ex: FR76...)',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 8),
                    ],
                    _toggleRow('PayPal', _paypalEnabled,
                        (v) => setState(() => _paypalEnabled = v)),

                    _sectionTitle('Modes de livraison'),
                    _checkboxRow('Colissimo', _colissimo,
                        (v) => setState(() => _colissimo = v ?? false)),
                    _checkboxRow('Mondial Relay', _mondialRelay,
                        (v) =>
                            setState(() => _mondialRelay = v ?? false)),
                    _checkboxRow('Retrait à la ferme', _retraitFerme,
                        (v) =>
                            setState(() => _retraitFerme = v ?? true)),

                    _sectionTitle('Délais de livraison'),
                    QarneaTextField(
                      controller: _delaisController,
                      placeholder: 'Ex: 3 à 5 jours ouvrés',
                    ),

                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
            ),

            Padding(
              padding:
                  EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: Column(
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(_errorMessage!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _continue,
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
                              'Terminer',
                              style: TextStyle(
                                fontFamily: 'HostGrotesk',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.32,
                              ),
                            ),
                    ),
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
