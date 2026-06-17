import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/colors.dart';
import '../widgets/step_bar.dart';
import '../theme/transitions.dart';
import 'producer_auth_screen.dart';

enum _QuestionType { yesNo, multipleChoice, textInput }

class _Question {
  final String text;
  final _QuestionType type;
  final List<String> options;
  final String? image;
  final Alignment imageAlignment;

  const _Question({
    required this.text,
    required this.type,
    this.options = const [],
    this.image,
    this.imageAlignment = Alignment.center,
  });
}

const _questions = [
  _Question(
    text: 'Tes animaux ont-ils un accès\nà un espace extérieur ?',
    type: _QuestionType.yesNo,
    image: 'assets/images/producer_card1.jpg',
    imageAlignment: Alignment(0.7, 0)
  ),
  _Question(
    text: 'Quelle alimentation utilises-tu principalement ?',
    type: _QuestionType.multipleChoice,
    options: [
      'Alimentation locale',
      'Sans OGM',
      'Alimentation conventionnelle',
      'Mixte',
    ],
    image: 'assets/images/producer_card2.jpg',
  ),
  _Question(
    text: 'Respectes-tu un délai avant la commercialisation après le traitement de médicaments ?',
    type: _QuestionType.yesNo,
    image: 'assets/images/producer_card3.jpg',
    imageAlignment: Alignment(0, -0.2)
  ),
  _Question(
    text: 'Quel est ton mode d\'élevage\nou de production ?',
    type: _QuestionType.multipleChoice,
    options: ['Plein air', 'Fermier', 'Agriculture biologique', 'Conventionnel'],
    image: 'assets/images/producer_card4.jpg',
  ),
  _Question(
    text: 'Limites-tu l\'usage de produits\nchimiques, pesticides ou\ntraitements intensifs ?',
    type: _QuestionType.yesNo,
    image: 'assets/images/producer_card5.jpg',
  ),
  _Question(
    text: 'Es-tu prêt.e à expliquer clairement\ntes pratiques aux consommateurs ?',
    type: _QuestionType.yesNo,
    image: 'assets/images/producer_card6.jpg',
  ),
  _Question(
    text: 'Serais-tu prêt.e à accepter\nune charte de qualité Qarnéa ?',
    type: _QuestionType.yesNo,
    image: 'assets/images/producer_card7.jpg',
  ),
  _Question(
    text: 'Selon vous que signifie\n« bien produire » ?',
    type: _QuestionType.textInput,
  ),
  _Question(
    text: 'Pourquoi souhaitez-vous\nrejoindre Qarnéa ?',
    type: _QuestionType.textInput,
  ),
];

class ProducerQuestionnaireScreen extends StatefulWidget {
  const ProducerQuestionnaireScreen({super.key});

  @override
  State<ProducerQuestionnaireScreen> createState() =>
      _ProducerQuestionnaireScreenState();
}

class _ProducerQuestionnaireScreenState
    extends State<ProducerQuestionnaireScreen> {
  // -1 = intro, 0..length-1 = questions, length = merci
  int _step = -1;
  final Map<int, dynamic> _answers = {};
  final _textController = TextEditingController();
  String? _pendingAnswer;

  bool get _isIntro => _step == -1;
  bool get _isMerci => _step >= _questions.length;
  _Question get _current => _questions[_step];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _answer(dynamic value) {
    setState(() {
      _answers[_step] = value;
      _textController.clear();
      _pendingAnswer = null;
      _step++;
    });
  }

  void _back() {
    if (_step <= -1) {
      Navigator.pop(context);
    } else {
      setState(() {
        _step--;
        if (_step >= 0 && _questions[_step].type == _QuestionType.textInput) {
          _textController.text = (_answers[_step] as String?) ?? '';
        }
      });
    }
  }

  void _goToAuth() {
    Navigator.of(context).pushReplacement(fadeRoute(const ProducerAuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final bottomPadding = mq.padding.bottom;
    final topPadding = mq.padding.top;

    if (_isIntro) return _buildIntro(screenH, mq.size.width, topPadding, bottomPadding);
    if (_isMerci) return _buildMerci(screenH, mq.size.width, bottomPadding);
    return _buildQuestion(screenH, mq.size.width, topPadding, bottomPadding);
  }

  // ── Intro ────────────────────────────────────────────────────────────────

  Widget _buildIntro(double screenH, double screenW, double topPadding, double bottomPadding) {
    // Coordonnées Figma: frame 430×932 — on scale proportionnellement
    final s = screenW / 430.0; // scale horizontal
    final v = screenH / 932.0; // scale vertical

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Background photo (Figma: crop centré d'un panoramique 4096px)
          Positioned.fill(
            child: Image.asset('assets/images/questionnaire_bg.jpg', fit: BoxFit.cover),
          ),

          // 2. Dark overlay rgba(0,0,0,0.2)
          Positioned.fill(
            child: Container(color: const Color(0x33000000)),
          ),

          // 3. Deco "Arrosées à la pluie bretonne" — left=-218, top=0, -36.92°
          Positioned(
            left: -218 * s,
            top: 0,
            width: 864.17 * s,
            height: 871.76 * s,
            child: Center(
              child: Transform.rotate(
                angle: -36.92 * math.pi / 180,
                child: SvgPicture.asset(
                  'assets/images/questionnaire_deco_bottom.svg',
                  width: 600.78 * s,
                  height: 639 * s,
                ),
              ),
            ),
          ),

          // 4. Deco "100% plein air vérifié" — left=27.56, top=-89.52, 83.04°
          Positioned(
            left: 27.56 * s,
            top: -89.52 * s,
            width: 567.94 * s,
            height: 666.15 * s,
            child: Center(
              child: Transform.rotate(
                angle: 83.04 * math.pi / 180,
                child: SvgPicture.asset(
                  'assets/images/questionnaire_deco_top.svg',
                  width: 610.35 * s,
                  height: 497.65 * s,
                ),
              ),
            ),
          ),

          // 5. White card — left=10, top=636, w=410, h=286 (s'adapte au bas safe area)
          Positioned(
            left: 10 * s,
            right: 10 * s,
            top: 636 * v,
            bottom: 10 * s + bottomPadding,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: QarneaColors.blanc,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          // 6. Titre — centré, top=666
          Positioned(
            left: 0,
            right: 0,
            top: 666 * v,
            child: Text(
              'Respectes-tu\nnos valeurs ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSauceTwo',
                fontSize: 28 * s,
                fontWeight: FontWeight.w900,
                color: QarneaColors.vertSapin,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),

          // 7. Oval sur "valeurs" — left=177, top=694, 110×44, rotated 180°
          Positioned(
            left: 177 * s,
            top: 694 * v,
            width: 110 * s,
            height: 44 * v,
            child: Transform.rotate(
              angle: math.pi,
              child: SvgPicture.asset(
                'assets/images/questionnaire_deco_valeurs.svg',
                fit: BoxFit.fill,
              ),
            ),
          ),

          // 8. Description — centré, top=759, w=318
          Positioned(
            left: 0,
            right: 0,
            top: 759 * v,
            child: Center(
              child: SizedBox(
                width: 318 * s,
                child: const Text(
                  'Nous allons faire un petit questionnaire pour voir si tu rentres dans notre charte éthique !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'HostGrotesk',
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: QarneaColors.vertSapin,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
            ),
          ),

          // 9. Bouton "Prêt !" — ancré en bas avec padding constant
          Positioned(
            left: 0,
            right: 0,
            bottom: 10 * s + bottomPadding + 16,
            child: Center(
              child: SizedBox(
                width: 350 * s,
                height: 41,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QarneaColors.vertCitron,
                    foregroundColor: QarneaColors.vertSapin,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Prêt !',
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
          ),

          // 10. Flèche retour — top=8.8%, left=4.65% du frame
          Positioned(
            top: topPadding + 8,
            left: 4,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: Colors.white),
              onPressed: _back,
            ),
          ),
        ],
      ),
    );
  }

  // ── Question ─────────────────────────────────────────────────────────────

  Widget _buildQuestion(
      double screenH, double screenW, double topPadding, double bottomPadding) {
    final q = _current;
    final s = screenW / 430.0;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back + step bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: QarneaColors.vertSapin,
                    onPressed: _back,
                  ),
                  Expanded(
                    child: StepBar(
                      total: _questions.length,
                      current: _step + 1,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenH * 0.022),

            // Qarnea Q doodle icon — Figma: 26×32px centré
            SvgPicture.asset(
              'assets/images/question_logo_q.svg',
              height: 32 * s,
            ),

            SizedBox(height: screenH * 0.022),

            // Question text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                q.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauceTwo',
                  fontSize: (screenH * 0.028).clamp(18.0, 26.0),
                  fontWeight: FontWeight.w900,
                  color: QarneaColors.vertSapin,
                  height: 1.3,
                ),
              ),
            ),

            const Spacer(),

            // Image uniquement pour yesNo — Figma: 389×370, radius 70
            if (q.type == _QuestionType.yesNo && q.image != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70 * s),
                  child: SizedBox(
                    width: 389 * s,
                    height: 370 * s,
                    child: Image.asset(q.image!, fit: BoxFit.cover, alignment: q.imageAlignment),
                  ),
                ),
              ),

            const Spacer(),

            // Answer buttons
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: _buildAnswers(q),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswers(_Question q) {
    if (q.type == _QuestionType.yesNo) {
      return Row(
        children: [
          Expanded(
            child: _PillButton(
              label: 'Non',
              color: QarneaColors.saumon,
              textColor: Colors.white,
              onTap: () => _answer(false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PillButton(
              label: 'Oui',
              color: QarneaColors.vertCitron,
              textColor: QarneaColors.vertSapin,
              onTap: () => _answer(true),
            ),
          ),
        ],
      );
    }

    if (q.type == _QuestionType.multipleChoice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...q.options.map((opt) {
            final isSelected = _pendingAnswer == opt;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () => setState(() => _pendingAnswer = opt),
                child: Container(
                  height: 63.75,
                  decoration: BoxDecoration(
                    color: QarneaColors.blanc,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected
                          ? QarneaColors.vertCitron
                          : QarneaColors.accentBlanc,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: const TextStyle(
                          fontFamily: 'HostGrotesk',
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: QarneaColors.vertSapin,
                          letterSpacing: -0.32,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? QarneaColors.vertCitron
                              : QarneaColors.blanc,
                          border: Border.all(
                            color: isSelected
                                ? QarneaColors.vertCitron
                                : QarneaColors.accentBlanc,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: QarneaColors.vertSapin)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          _PillButton(
            label: 'Suivant',
            color: _pendingAnswer != null
                ? QarneaColors.vertCitron
                : QarneaColors.accentBlanc,
            textColor: _pendingAnswer != null
                ? QarneaColors.vertSapin
                : QarneaColors.textLight,
            onTap: () {
              if (_pendingAnswer != null) _answer(_pendingAnswer!);
            },
          ),
        ],
      );
    }

    // textInput
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: QarneaColors.blanc,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: QarneaColors.accentBlanc),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'HostGrotesk',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: QarneaColors.vertSapin,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              hintText: 'Votre réponse...',
              hintStyle: TextStyle(
                fontFamily: 'HostGrotesk',
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: QarneaColors.textLight,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PillButton(
          label: 'Continuer',
          color: QarneaColors.vertCitron,
          textColor: QarneaColors.vertSapin,
          onTap: () {
            final text = _textController.text.trim();
            if (text.isNotEmpty) _answer(text);
          },
        ),
      ],
    );
  }

  // ── Merci ─────────────────────────────────────────────────────────────────

  Widget _buildMerci(double screenH, double screenW, double bottomPadding) {
    final s = screenW / 430.0;
    final v = screenH / 932.0;

    return Scaffold(
      backgroundColor: QarneaColors.blancCasse,
      body: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Doodle Q1 — bas-gauche, Figma: inset[34.98%,-25.84%,-0.07%,-28.69%], -156.77°
          Positioned(
            left: -123 * s,
            top: 326 * v,
            width: 664 * s,
            height: 607 * v,
            child: Center(
              child: Transform.rotate(
                angle: -156.77 * math.pi / 180,
                child: SvgPicture.asset(
                  'assets/images/merci_deco_q1.svg',
                  width: 539 * s,
                  height: 429 * v,
                ),
              ),
            ),
          ),
          // Doodle Q2 — haut-droit, Figma: inset[-5.07%,-18.36%,66.39%,18.26%], -75.84°
          Positioned(
            left: 78.5 * s,
            top: -47.25 * v,
            width: 430.45 * s,
            height: 360.35 * v,
            child: Center(
              child: Transform.rotate(
                angle: -75.84 * math.pi / 180,
                child: SvgPicture.asset(
                  'assets/images/merci_deco_q2.svg',
                  width: 277.5 * s,
                  height: 373.9 * v,
                ),
              ),
            ),
          ),
          // Contenu
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/question_logo_q.svg',
                          height: 32 * s,
                        ),
                        SizedBox(height: screenH * 0.04),
                        Text(
                          'Merci beaucoup\npour tes réponses !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'OpenSauceTwo',
                            fontSize: (screenH * 0.032).clamp(22.0, 30.0),
                            fontWeight: FontWeight.w900,
                            color: QarneaColors.vertSapin,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: screenH * 0.025),
                        Text(
                          'Nous allons vérifier tout ça, et nous t\'enverrons à l\'adresse suivante la réponse à ta demande.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: (screenH * 0.018).clamp(13.0, 17.0),
                            fontWeight: FontWeight.w300,
                            color: Colors.black87,
                            letterSpacing: -0.28,
                          ),
                        ),
                        SizedBox(height: screenH * 0.02),
                        Text(
                          'En attendant, créons ton compte pour finaliser ton inscription.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'HostGrotesk',
                            fontSize: (screenH * 0.016).clamp(12.0, 16.0),
                            fontWeight: FontWeight.w400,
                            color: QarneaColors.vertSapin,
                            letterSpacing: -0.24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
                  child: _PillButton(
                    label: 'Continuer',
                    color: QarneaColors.vertCitron,
                    textColor: QarneaColors.vertSapin,
                    onTap: _goToAuth,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared button ─────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'HostGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.32,
          ),
        ),
      ),
    );
  }
}
