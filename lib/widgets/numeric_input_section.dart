import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'section_card.dart';

class NumericInputSection extends StatefulWidget {
  const NumericInputSection({
    super.key,
    required this.emoji,
    required this.title,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
  });

  final String emoji;
  final String title;
  final String hint;
  final int? initialValue;
  final ValueChanged<int?> onChanged;

  @override
  State<NumericInputSection> createState() => _NumericInputSectionState();
}

class _NumericInputSectionState extends State<NumericInputSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _helperText(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '≈ $mins Minutes';
    if (mins == 0) return '≈ $hours Hour${hours > 1 ? 's' : ''}';
    return '≈ $hours Hour${hours > 1 ? 's' : ''} $mins Minutes';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = int.tryParse(_controller.text);
    return SectionCard(
      emoji: widget.emoji,
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixText: 'min',
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              widget.onChanged(parsed);
              setState(() {});
            },
          ),
          if (_helperText(minutes).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _helperText(minutes),
              style: const TextStyle(
                color: AppColors.rosePink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
