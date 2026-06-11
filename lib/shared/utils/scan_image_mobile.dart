import 'dart:io';

import 'package:flutter/material.dart';

Widget buildScanImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => _placeholder(width, height),
  );
}

Widget _placeholder(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    color: Colors.grey.shade300,
    child: const Icon(Icons.monetization_on),
  );
}
