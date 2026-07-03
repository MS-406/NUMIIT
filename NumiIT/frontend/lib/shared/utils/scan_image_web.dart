import 'package:flutter/material.dart';

Widget buildScanImage(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  VoidCallback? onError,
}) {
  Widget errorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    if (onError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onError());
    }
    return _placeholder(width, height);
  }

  return Image.network(
    path,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
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
