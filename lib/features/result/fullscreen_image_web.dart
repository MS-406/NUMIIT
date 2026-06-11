import 'package:flutter/material.dart';

void openFullscreenImage(BuildContext context, String imagePath) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      child: InteractiveViewer(
        child: Image.network(imagePath),
      ),
    ),
  );
}
