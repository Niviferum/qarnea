import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../models/producer_form_data.dart';
import '../widgets/qarnea_text_field.dart';
import '../widgets/step_bar.dart';
import 'producer_logistics_screen.dart';
import '../theme/transitions.dart';

class ProducerProfileScreen extends StatefulWidget {
  final ProducerFormData formData;
  const ProducerProfileScreen({super.key, required this.formData});

  @override
  State<ProducerProfileScreen> createState() =>
      _ProducerProfileScreenState();
}

class _ProducerProfileScreenState extends State<ProducerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState!.validate()) {
      widget.formData.description = _bioController.text.trim();

      Navigator.of(context).push(
        fadeRoute(ProducerLogisticsScreen(formData: widget.formData)),
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
                  const Expanded(child: StepBar(total: 4, current: 3)),
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
                        'Dis-nous en plus sur toi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'OpenSauceTwo',
                          fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                          fontWeight: FontWeight.w900,
                          color: QarneaColors.vertSapin,
                        ),
                      ),
                      SizedBox(height: screenH * 0.035),

                      // Photo upload placeholder
                      GestureDetector(
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Upload photo non disponible pour l\'instant')),
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: QarneaColors.blanc,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: QarneaColors.accentBlanc,
                                width: 2),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: QarneaColors.textLight,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ajouter une photo',
                        style: TextStyle(
                          fontFamily: 'HostGrotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: QarneaColors.textLight,
                        ),
                      ),

                      SizedBox(height: screenH * 0.03),

                      QarneaTextField(
                        controller: _bioController,
                        placeholder:
                            'Parle-nous de toi, de ton exploitation...',
                        maxLines: 4,
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
