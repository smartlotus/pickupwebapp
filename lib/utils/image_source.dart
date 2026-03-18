import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'image_source_stub.dart'
    if (dart.library.io) 'image_source_io.dart'
    if (dart.library.html) 'image_source_web.dart' as platform;

ImageProvider<Object>? imageProviderFromStoredSource(String? source) {
  final normalized = source?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  final bytes = _tryDecodeImageDataUri(normalized);
  if (bytes != null) {
    return MemoryImage(bytes);
  }

  return platform.imageProviderFromSource(normalized);
}

Uint8List? _tryDecodeImageDataUri(String value) {
  if (!value.startsWith('data:image/')) {
    return null;
  }

  final commaIndex = value.indexOf(',');
  if (commaIndex == -1) {
    return null;
  }

  final metadata = value.substring(0, commaIndex).toLowerCase();
  if (!metadata.endsWith(';base64')) {
    return null;
  }

  try {
    return base64Decode(value.substring(commaIndex + 1));
  } catch (_) {
    return null;
  }
}
