import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/producer_form_data.dart';
import '../widgets/qarnea_text_field.dart';
import '../widgets/step_bar.dart';
import 'producer_profile_screen.dart';
import '../theme/transitions.dart';

class ProducerShopScreen extends StatefulWidget {
  final ProducerFormData formData;
  const ProducerShopScreen({super.key, required this.formData});

  @override
  State<ProducerShopScreen> createState() => _ProducerShopScreenState();
}

class _ProducerShopScreenState extends State<ProducerShopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomBoutiqueController = TextEditingController();
  final _siretController = TextEditingController();
  final _tvaController = TextEditingController();
  final _adresseController = TextEditingController();
  final _localisationController = TextEditingController();
  String? _typeStructure;

  static const _typeOptions = [
    'Auto-entrepreneur',
    'SAS',
    'SARL',
    'EURL',
    'SCI',
    'Association',
  ];

  @override
  void dispose() {
    _nomBoutiqueController.dispose();
    _siretController.dispose();
    _tvaController.dispose();
    _adresseController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      final loc = _localisationController.text.trim();
      final parts = loc.split(',');
      widget.formData
        ..nomExploitation = _nomBoutiqueController.text.trim()
        ..raisonSociale =
            '${_typeStructure ?? ''} ${_nomBoutiqueController.text.trim()}'.trim()
        ..siret = _siretController.text.replaceAll(RegExp(r'\D'), '')
        ..adresseLigne1 = _adresseController.text.trim()
        ..ville = parts.isNotEmpty ? parts[0].trim() : loc
        ..region = parts.length > 1 ? parts[1].trim() : loc
        ..departement = parts.length > 1 ? parts[1].trim() : loc;

      Navigator.of(context).push(
        fadeRoute(ProducerProfileScreen(formData: widget.formData)),
      );
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
                  const Expanded(child: StepBar(total: 4, current: 2)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenH * 0.03),
                      Text(
                        'Création de ta vitrine',
                        style: TextStyle(
                          fontFamily: 'OpenSauceTwo',
                          fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                          fontWeight: FontWeight.w900,
                          color: QarneaColors.vertSapin,
                        ),
                      ),
                      SizedBox(height: screenH * 0.03),

                      QarneaTextField(
                        controller: _nomBoutiqueController,
                        placeholder: 'Nom de ta boutique',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Champ requis'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Type de structure dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _typeStructure,
                        hint: const Text(
                          'Type de structure',
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: QarneaColors.textLight,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'HostGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: QarneaColors.vertSapin,
                        ),
                        dropdownColor: QarneaColors.blanc,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: QarneaColors.blanc,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: QarneaColors.accentBlanc),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: QarneaColors.accentBlanc),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: QarneaColors.vertSapin, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(color: Colors.red),
                          ),
                        ),
                        items: _typeOptions
                            .map((o) => DropdownMenuItem(
                                  value: o,
                                  child: Text(o),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _typeStructure = v),
                        validator: (v) =>
                            v == null ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _siretController,
                        placeholder: 'Numéro SIRET (14 chiffres)',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Champ requis';
                          }
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length != 14) {
                            return 'SIRET invalide (14 chiffres)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _tvaController,
                        placeholder:
                            'Numéro TVA intracommunautaire (optionnel)',
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _adresseController,
                        placeholder: 'Adresse',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Champ requis'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      QarneaTextField(
                        controller: _localisationController,
                        placeholder: 'Ville, Région',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Champ requis'
                                : null,
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
                  onPressed: _continue,
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
