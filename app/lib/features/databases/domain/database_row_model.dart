
class DatabaseRowModel {
  final String id;
  final String databaseId;
  final String pageId;
  final double position;
  final int createdAt;
  final int updatedAt;
  final Map<String, PropertyValue> values; // propertyId -> value

  const DatabaseRowModel({
    required this.id,
    required this.databaseId,
    required this.pageId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.values,
  });
}

sealed class PropertyValue {
  const PropertyValue();
}

class TextValue extends PropertyValue {
  final String value;
  const TextValue(this.value);
}

class NumberValue extends PropertyValue {
  final double value;
  const NumberValue(this.value);
}

class DateValue extends PropertyValue {
  final DateTime value;
  const DateValue(this.value);
}

class CheckboxValue extends PropertyValue {
  final bool value;
  const CheckboxValue(this.value);
}

class SelectValue extends PropertyValue {
  final String optionId;
  const SelectValue(this.optionId);
}
