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
  divider,
  image,
  database,
  // Slash-menu-only entries: both create a `database` block, differing only in
  // the initial view. They are never stored as a block type.
  databaseTable,
  databaseGallery;

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
        BlockType.image => 'image',
        BlockType.database => 'database',
        BlockType.databaseTable => 'database_table',
        BlockType.databaseGallery => 'database_gallery',
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
        'image' => BlockType.image,
        'database' => BlockType.database,
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
        BlockType.image => 'Image',
        BlockType.database => 'Database',
        BlockType.databaseTable => 'Table',
        BlockType.databaseGallery => 'Gallery',
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
        BlockType.image => Icons.image_outlined,
        BlockType.database => Icons.grid_view,
        BlockType.databaseTable => Icons.table_chart,
        BlockType.databaseGallery => Icons.grid_view,
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
