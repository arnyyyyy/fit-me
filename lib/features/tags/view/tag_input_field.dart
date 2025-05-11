import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class TagInputField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onTagAdded;

  const TagInputField({
    super.key,
    this.controller,
    required this.onTagAdded,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).enterNewTag,
              hintStyle: AppTextStyles.subtitle.copyWith(
                color: AppColors.text.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                widget.onTagAdded(value.trim());
                _controller.clear();
              }
            },
            style: AppTextStyles.body,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _addTag,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onTagAdded(text);
      _controller.clear();
    }
  }
}
