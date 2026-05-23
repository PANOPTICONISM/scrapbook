import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkEditorPopover extends StatefulWidget {
  /// Existing URL, or null when adding a new link.
  final String? initialUrl;

  /// Called with the new URL (empty string means "remove the link").
  /// Not called if the user cancels.
  final void Function(String url) onApply;

  final VoidCallback onCancel;

  const LinkEditorPopover({
    super.key,
    required this.initialUrl,
    required this.onApply,
    required this.onCancel,
  });

  @override
  State<LinkEditorPopover> createState() => _LinkEditorPopoverState();
}

class _LinkEditorPopoverState extends State<LinkEditorPopover> {
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialUrl ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
        _ctrl.selection =
            TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() => widget.onApply(_ctrl.text.trim());

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onCancel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialUrl != null;

    return TapRegion(
      onTapOutside: (_) => widget.onCancel(),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: _handleKey,
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'https://example.com',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (isEditing)
              IconButton(
                tooltip: 'Remove link',
                icon: const Icon(Icons.link_off, size: 18, color: Colors.red),
                onPressed: () => widget.onApply(''),
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              tooltip: 'Apply',
              icon: const Icon(Icons.check, size: 18),
              onPressed: _submit,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
