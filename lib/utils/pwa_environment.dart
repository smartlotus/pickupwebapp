import 'pwa_environment_stub.dart'
    if (dart.library.html) 'pwa_environment_web.dart' as impl;

bool shouldShowIosInstallBanner() {
  try {
    return impl.shouldShowIosInstallBanner();
  } catch (_) {
    return false;
  }
}

bool isStandalonePwa() {
  try {
    return impl.isStandalonePwa();
  } catch (_) {
    return false;
  }
}
