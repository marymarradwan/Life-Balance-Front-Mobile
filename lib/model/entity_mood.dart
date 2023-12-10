import 'dart:core';


class EntityMood {
  int mood_id;
  int entity_id;
  int entity_type;

  EntityMood(
    this.mood_id,
    this.entity_id,
    this.entity_type,
  );

  @override
  String toString() {
    return 'EntityMood{mood_id: $mood_id, entity_id: $entity_id, entity_type: $entity_type}';
  }
}
