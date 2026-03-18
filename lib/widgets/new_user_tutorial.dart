import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/capsule_provider.dart';

class NewUserTutorial extends StatefulWidget {
  final VoidCallback onFinish;

  const NewUserTutorial({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<NewUserTutorial> createState() => _NewUserTutorialState();
}

class _NewUserTutorialState extends State<NewUserTutorial> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_index >= total - 1) {
      widget.onFinish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final steps = <_TutorialStep>[
      _TutorialStep(
        icon: Icons.radio_button_checked_outlined,
        title: provider.t('tutorial_step1_title'),
        desc: provider.t('tutorial_step1_desc'),
      ),
      _TutorialStep(
        icon: Icons.add_circle_outline,
        title: provider.t('tutorial_step2_title'),
        desc: provider.t('tutorial_step2_desc'),
      ),
      _TutorialStep(
        icon: Icons.psychology_alt_outlined,
        title: provider.t('tutorial_step3_title'),
        desc: provider.t('tutorial_step3_desc'),
      ),
      _TutorialStep(
        icon: Icons.tune_outlined,
        title: provider.t('tutorial_step4_title'),
        desc: provider.t('tutorial_step4_desc'),
      ),
    ];

    return Material(
      color: Colors.black.withOpacity(0.97),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Pickup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: widget.onFinish,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: provider.t('tutorial_skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: steps.length,
                itemBuilder: (context, i) {
                  final step = steps[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white30, width: 1.1),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54),
                            ),
                            child: Icon(step.icon, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white24),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                _LineBox(width: 0.94),
                                const SizedBox(height: 10),
                                _LineBox(width: 0.72),
                                const SizedBox(height: 10),
                                _LineBox(width: 0.86),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${i + 1}/${steps.length}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: Row(
                children: [
                  TextButton(
                    onPressed: widget.onFinish,
                    child: Text(
                      provider.t('tutorial_skip'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(steps.length, (i) {
                      final active = i == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => _next(steps.length),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _index == steps.length - 1
                          ? provider.t('tutorial_start')
                          : provider.t('tutorial_next'),
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

class _TutorialStep {
  final IconData icon;
  final String title;
  final String desc;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _LineBox extends StatelessWidget {
  final double width;

  const _LineBox({required this.width});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(0.16),
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }
}

