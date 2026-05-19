import 'package:flutter/material.dart';

enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletedList,
  numberedList,
  todo,
  quote,
  code,
  divider;

  String get value => switch (this) {
        BlockType.paragraph => 'paragraph',
        BlockType.heading1 => 'h1',
        BlockType.heading2 => 'h2',
        BlockType.heading3 => 'h3',
        BlockType.bulletedList => 'bullet',
        BlockType.numberedList => 'number',
        BlockType.todo => 'todo',
        BlockType.quote => 'quote',
        BlockType.code => 'code',
        BlockType.divider => 'divider',
      };

  static BlockType fromString(String s) => switch (s) {
        'h1' => BlockType.heading1,
        'h2' => BlockType.heading2,
        'h3' => BlockType.heading3,
        'bullet' => BlockType.bulletedList,
        'number' => BlockType.numberedList,
        'todo' => BlockType.todo,
        'quote' => BlockType.quote,
        'code' => BlockType.code,
        'divider' => BlockType.divider,
        _ => BlockType.paragraph,
      };

  String get label => switch (this) {
        BlockType.paragraph => 'Text',
        BlockType.heading1 => 'Heading 1',
        BlockType.heading2 => 'Heading 2',
        BlockType.heading3 => 'Heading 3',
        BlockType.bulletedList => 'Bulleted list',
        BlockType.numberedList => 'Numbered list',
        BlockType.todo => 'To-do',
        BlockType.quote => 'Quote',
        BlockType.code => 'Code',
        BlockType.divider => 'Divider',
      };

  IconData get icon => switch (this) {
        BlockType.paragraph => Icons.notes,
        BlockType.heading1 => Icons.title,
        BlockType.heading2 => Icons.text_fields,
        BlockType.heading3 => Icons.text_format,
        BlockType.bulletedList => Icons.format_list_bulleted,
        BlockType.numberedList => Icons.format_list_numbered,
        BlockType.todo => Icons.check_box_outlined,
        BlockType.quote => Icons.format_quote,
        BlockType.code => Icons.code,
        BlockType.divider => Icons.horizontal_rule,
      };

  String get hint => switch (this) {
        BlockType.heading1 => 'Heading 1',
        BlockType.heading2 => 'Heading 2',
        BlockType.heading3 => 'Heading 3',
        BlockType.bulletedList => 'List item',
        BlockType.numberedList => 'List item',
        BlockType.todo => 'To-do',
        BlockType.quote => 'Quote',
        BlockType.code => 'Code',
        _ => "Type '/' for commands",
      };
}
