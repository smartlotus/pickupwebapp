import 'dart:ui';

import 'package:flutter/material.dart';

class LaunchIntroOverlay extends StatefulWidget {
  const LaunchIntroOverlay({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<LaunchIntroOverlay> createState() => _LaunchIntroOverlayState();
}

class _LaunchIntroOverlayState extends State<LaunchIntroOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _timeline;

  late final Animation<double> _overlayOpacity;
  late final Animation<double> _overlayBlur;

  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _markOffsetY;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoOffsetY;
  late final Animation<double> _logoScale;

  late final Animation<double> _nameOpacity;
  late final Animation<double> _nameOffsetY;

  late final Animation<double> _sloganOpacity;
  late final Animation<double> _sloganOffsetY;
  late final Animation<double> _sloganLetterSpacing;

  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _overlayOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.86, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _overlayBlur = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.86, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _markOpacity = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _markScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );
    _markOffsetY = Tween<double>(begin: -16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutCubic),
      ),
    );
    _logoOffsetY = Tween<double>(begin: -26.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutCubic),
      ),
    );
    _logoScale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.06, 0.34, curve: Curves.easeOutCubic),
      ),
    );

    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.16, 0.42, curve: Curves.easeOutCubic),
      ),
    );
    _nameOffsetY = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.16, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    _sloganOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.24, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _sloganOffsetY = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.24, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _sloganLetterSpacing = Tween<double>(begin: 10.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _timeline,
        curve: const Interval(0.24, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _timeline.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showOverlay = false);
      }
    });
    _timeline.forward();
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) return widget.child;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: true,
          child: AnimatedBuilder(
            animation: _timeline,
            builder: (context, _) {
              final size = MediaQuery.of(context).size;
              final markWidth = size.width * 1.45;
              final markHeight = size.height * 0.70;

              return Opacity(
                opacity: _overlayOpacity.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _overlayBlur.value,
                    sigmaY: _overlayBlur.value,
                  ),
                  child: ColoredBox(
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Align(
                          alignment: const Alignment(0, 0.34),
                          child: Transform.translate(
                            offset: Offset(0, _markOffsetY.value),
                            child: Transform.scale(
                              scale: _markScale.value,
                              child: Opacity(
                                opacity: _markOpacity.value,
                                child: SizedBox(
                                  width: markWidth,
                                  height: markHeight,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: const Text(
                                        '/n',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 900,
                                          fontWeight: FontWeight.w800,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Transform.translate(
                            offset: const Offset(0, -18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _logoOffsetY.value),
                                    child: Transform.scale(
                                      scale: _logoScale.value,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Image.asset(
                                          'assets/branding/pickuplogo.png',
                                          width: 110,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) {
                                            return Image.network(
                                              'pickuplogo.png',
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, ___, ____) {
                                                return Image.asset(
                                                  'assets/branding/pickuplogo.jpg',
                                                  width: 110,
                                                  height: 110,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Opacity(
                                  opacity: _nameOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _nameOffsetY.value),
                                    child: const Text(
                                      'Pickup',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 56,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Opacity(
                                  opacity: _sloganOpacity.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _sloganOffsetY.value),
                                    child: Text(
                                      '把零碎的生活装进去',
                                      style: TextStyle(
                                        color: const Color(0xFF555555),
                                        fontSize: 31,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing:
                                            _sloganLetterSpacing.value,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
