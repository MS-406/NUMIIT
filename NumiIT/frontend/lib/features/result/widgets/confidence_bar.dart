import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ConfidenceBar extends StatefulWidget {
  const ConfidenceBar({super.key, required this.confidence});

  final double confidence;

  @override
  State<ConfidenceBar> createState() => _ConfidenceBarState();
}

class _ConfidenceBarState extends State<ConfidenceBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.confidence >= 0.8
        ? AppColors.successGreen
        : (widget.confidence >= 0.6 ? AppColors.warningOrange : Colors.red);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: widget.confidence * _controller.value,
          minHeight: 5,
          backgroundColor: Colors.grey.shade200,
          color: color,
        ),
      ),
    );
  }
}
