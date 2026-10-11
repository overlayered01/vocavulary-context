import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/word.dart';
import '../theme.dart';

class MeaningList extends StatelessWidget {
  final List<String> meanings;
  final TextStyle? style;
  const MeaningList({super.key, required this.meanings, this.style});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < meanings.length; i++)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
          child: Text(
            '${meanings.length > 1 ? '${i + 1}. ' : ''}${meanings[i]}',
            style: style,
          ),
        ),
    ],
  );
}

class MeaningFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final bool required;

  const MeaningFields({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < controllers.length; i++)
          Padding(
            key: ObjectKey(controllers[i]),
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: controllers[i],
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: controllers.length == 1
                    ? (required
                          ? context.l10n.meaningFieldsLabelRequired
                          : context.l10n.meaningFieldsLabel)
                    : context.l10n.meaningFieldsLabelNumbered(i + 1),
                suffixIcon: controllers.length > 1
                    ? IconButton(
                        tooltip: context.l10n.meaningFieldsRemove(i + 1),
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => onRemove(i),
                      )
                    : null,
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.l10n.meaningFieldsAdd),
          ),
        ),
      ],
    );
  }
}

Future<List<String>?> showMeaningEditor(
  BuildContext context,
  List<String> meanings,
) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _MeaningDialog(meanings: meanings),
  );
}

class _MeaningDialog extends StatefulWidget {
  final List<String> meanings;
  const _MeaningDialog({required this.meanings});

  @override
  State<_MeaningDialog> createState() => _MeaningDialogState();
}

class _MeaningDialogState extends State<_MeaningDialog> {
  late final List<TextEditingController> _controllers = [
    for (final value in widget.meanings.isEmpty ? [''] : widget.meanings)
      TextEditingController(text: value),
  ];
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    final values = Word.normalizeMeanings(_controllers.map((c) => c.text));
    if (values.isEmpty) {
      setState(() => _error = context.l10n.meaningFieldsEmptyError);
      return;
    }
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.meaningFieldsEditTitle),
      scrollable: true,
      content: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MeaningFields(
              controllers: _controllers,
              onAdd: () =>
                  setState(() => _controllers.add(TextEditingController())),
              onRemove: (i) {
                final removed = _controllers[i];
                setState(() => _controllers.removeAt(i));
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => removed.dispose(),
                );
              },
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: AppColors.sub)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        ElevatedButton(onPressed: _save, child: Text(context.l10n.commonSave)),
      ],
    );
  }
}
