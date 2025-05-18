// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarEventDayAdapter extends TypeAdapter<CalendarEventDay> {
  @override
  final int typeId = 3;

  @override
  CalendarEventDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalendarEventDay(
      date: fields[0] as DateTime,
      collages: (fields[1] as List).cast<SavedCollage?>(),
    );
  }

  @override
  void write(BinaryWriter writer, CalendarEventDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.collages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEventDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
