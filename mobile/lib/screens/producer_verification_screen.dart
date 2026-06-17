import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/transitions.dart';
import 'welcome_screen.dart';

class ProducerVerificationScreen extends StatefulWidget {
  const ProducerVerificationScreen({super.key});

  @override
  State<ProducerVerificationScreen> createState() =>
      _ProducerVerificationScreenState();
}

class _ProducerVerificationScreenState
    extends State<ProducerVerificationScreen> {
  bool _idUploaded = false;

  void _simulateUpload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload de document non disponible pour l\'instant')),
    );
    setState(() => _idUploaded = true);
  }

  void _finish() {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const WelcomeScreen()),
      (_) => false,
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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenH * 0.04),

                    Text(
                      'Super merci !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'OpenSauceTwo',
                        fontSize: (screenH * 0.034).clamp(22.0, 32.0),
                        fontWeight: FontWeight.w900,
                        color: QarneaColors.vertSapin,
                      ),
                    ),

                    SizedBox(height: screenH * 0.015),

                    Text(
                      'On vérifie que tout est bon avec...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: (screenH * 0.019).clamp(14.0, 18.0),
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),

                    SizedBox(height: screenH * 0.05),

                    GestureDetector(
                      onTap: _simulateUpload,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: QarneaColors.blanc,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _idUploaded
                                ? QarneaColors.vertCitron
                                : QarneaColors.accentBlanc,
                            width: _idUploaded ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: QarneaColors.blancCasse,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _idUploaded
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.badge_outlined,
                                color: _idUploaded
                                    ? QarneaColors.vertCitron
                                    : QarneaColors.vertSapin,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pièce d\'identité',
                                    style: TextStyle(
                                      fontFamily: 'OpenSauceTwo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: QarneaColors.vertSapin,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _idUploaded
                                        ? 'Document ajouté'
                                        : 'Carte nationale d\'identité ou passeport',
                                    style: TextStyle(
                                      fontFamily: 'HostGrotesk',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                      color: _idUploaded
                                          ? QarneaColors.vertSapin
                                          : QarneaColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _idUploaded
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: _idUploaded
                                  ? QarneaColors.vertCitron
                                  : QarneaColors.accentBlanc,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: screenH * 0.04),

                    Text(
                      'Votre document sera utilisé uniquement pour vérifier votre identité et ne sera pas partagé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'HostGrotesk',
                        fontSize: (screenH * 0.015).clamp(11.0, 14.0),
                        fontWeight: FontWeight.w300,
                        color: QarneaColors.textLight,
                        letterSpacing: -0.2,
                      ),
                    ),

                    SizedBox(height: screenH * 0.04),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QarneaColors.vertCitron,
                    foregroundColor: QarneaColors.vertSapin,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
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
            ),
          ],
        ),
      ),
    );
  }
}
