import 'dart:html' as html;
import 'dart:js_util' as js_util;

bool shouldShowIosInstallBanner() {
  if (isStandalonePwa()) {
    return false;
  }

  final ua = html.window.navigator.userAgent.toLowerCase();
  final isIos = ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
  final isSafari = ua.contains('safari') &&
      !ua.contains('crios') &&
      !ua.contains('fxios') &&
      !ua.contains('edgios');
  return isIos && isSafari;
}

bool isStandalonePwa() {
  final standaloneMedia = html.window.matchMedia('(display-mode: standalone)').matches;
  bool standaloneNavigator = false;
  try {
    final dynamic value = js_util.getProperty(html.window.navigator, 'standalone');
    standaloneNavigator = value == true;
  } catch (_) {
    standaloneNavigator = false;
  }
  return standaloneMedia || standaloneNavigator;
}
