// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_collage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedCollageAdapter extends TypeAdapter<SavedCollage> {
  @override
  final int typeId = 2;

  @override
  SavedCollage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedCollage(
      name: fields[0] as String,
      imagePath: fields[1] as String,
      tags: (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedCollage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedCollageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
