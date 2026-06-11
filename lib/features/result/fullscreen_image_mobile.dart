import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void openFullscreenImage(BuildContext context, String imagePath) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          minScale: PhotoViewComputedScale.contained,
        ),
      ),
    ),
  );
}
