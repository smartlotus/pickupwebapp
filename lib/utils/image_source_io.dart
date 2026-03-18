import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object>? imageProviderFromSource(String source) {
  if (source.startsWith('http://') ||
      source.startsWith('https://') ||
      source.startsWith('blob:')) {
    return NetworkImage(source);
  }

  return FileImage(File(source));
}
