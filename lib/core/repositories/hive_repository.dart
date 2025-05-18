import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/collages/model/saved_collage.dart';
import '../../features/wardrobe/model/saved_image.dart';
import '../../features/tags/model/tag.dart';
import '../../features/calendar/model/model.dart';

class HiveRepository {
  static Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    
    Hive.registerAdapter(SavedImageAdapter());
    Hive.registerAdapter(SavedCollageAdapter());
    Hive.registerAdapter(TagAdapter());
    Hive.registerAdapter(CalendarEventDayAdapter());
  }

  Future<List<SavedImage>> getAllImages() async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    return box.values.toList();
  }

  Future<void> addImage(SavedImage image) async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    await box.add(image);
  }

  Future<void> deleteImage(SavedImage image) async {
    await image.delete();
  }

  Future<List<SavedCollage>> getAllCollages() async {
    final box = await Hive.openBox<SavedCollage>('collagesBox');
    return box.values.toList();
  }

  Future<void> addCollage(SavedCollage collage) async {
    final box = await Hive.openBox<SavedCollage>('collagesBox');
    await box.add(collage);
  }

  Future<void> deleteCollage(SavedCollage collage) async {
    await collage.delete();
  }

  Future<List<String>> getAllTags() async {
    final imagesBox = await Hive.openBox<SavedImage>('imagesBox');
    final collagesBox = await Hive.openBox<SavedCollage>('collagesBox');
    
    final Set<String> tagsSet = {};
    for (var img in imagesBox.values) {
      tagsSet.addAll(img.tags);
    }
    for (var collage in collagesBox.values) {
      tagsSet.addAll(collage.tags);
    }
    return tagsSet.toList()..sort();
  }

  Future<List<CalendarEventDay>> getAllCalendarEvents() async {
    final box = await Hive.openBox<CalendarEventDay>('calendarEventsBox');
    return box.values.toList();
  }
  
  Future<void> addCalendarEvent(CalendarEventDay event) async {
    final box = await Hive.openBox<CalendarEventDay>('calendarEventsBox');
    await box.add(event);
  }
  
  Future<void> updateCalendarEvents(List<CalendarEventDay> events) async {
    final box = await Hive.openBox<CalendarEventDay>('calendarEventsBox');
    await box.clear();
    
    for (final event in events) {
      if (event.hasAnyCollage) {
        await box.add(event);
      }
    }
  }
  
  Future<void> deleteCalendarEvent(CalendarEventDay event) async {
    try {
      if (event.isInBox) {
        await event.delete();
      }
    } catch (e) {
    }
  }
}