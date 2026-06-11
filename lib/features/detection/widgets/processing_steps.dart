import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/scan_provider.dart';

class ProcessingSteps extends StatelessWidget {
  const ProcessingSteps({
    super.key,
    required this.currentStep,
    required this.isComplete,
  });

  final ProcessingStep currentStep;
  final bool isComplete;

  static const _labels = ['Preprocess', 'Classify', 'OCR'];

  @override
  Widget build(BuildContext context) {
    final stepIndex = currentStep.index;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Connected Timeline Row
        Row(
          children: [
            _buildStepCircle(0, stepIndex, isComplete),
            _buildStepLine(0, stepIndex, isComplete),
            _buildStepCircle(1, stepIndex, isComplete),
            _buildStepLine(1, stepIndex, isComplete),
            _buildStepCircle(2, stepIndex, isComplete),
          ],
        ),
        const SizedBox(height: 6),
        // Step Labels Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_labels[0], style: AppTypography.body(11, color: AppColors.textSecondary, weight: FontWeight.w500)),
            Text(_labels[1], style: AppTypography.body(11, color: AppColors.textSecondary, weight: FontWeight.w500)),
            Text(_labels[2], style: AppTypography.body(11, color: AppColors.textSecondary, weight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isComplete
              ? 'Analysis complete'
              : 'Step ${stepIndex + 1} of 3 — ${_labels[stepIndex]}',
          style: AppTypography.body(13, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepCircle(int i, int currentStepIndex, bool isComplete) {
    final done = isComplete || i < currentStepIndex;
    final active = !isComplete && i == currentStepIndex;
    return CircleAvatar(
      radius: 13,
      backgroundColor: done
          ? AppColors.accent
          : (active ? AppColors.primaryMid : Colors.grey.shade300),
      child: done
          ? const Icon(Icons.check, size: 14, color: AppColors.primaryDark)
          : active
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              : Text(
                  '${i + 1}',
                  style: AppTypography.body(11, color: Colors.white, weight: FontWeight.bold),
                ),
    );
  }

  Widget _buildStepLine(int i, int currentStepIndex, bool isComplete) {
    final done = isComplete || currentStepIndex > i;
    return Expanded(
      child: Container(
        height: 2,
        color: done ? AppColors.accent : Colors.grey.shade300,
      ),
    );
  }
}
