import 'package:ghii/models/repository.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static const String _boxName = 'repositories';
  late Box<Map> _box;
  bool _initialized = false;

  DatabaseHelper._internal();

  Future<void> initialize() async {
    if (!_initialized) {
      await Hive.initFlutter();
      _box = await Hive.openBox<Map>(_boxName);
      _initialized = true;
    }
  }

  Future<Box<Map>> get box async {
    if (!_initialized) {
      await initialize();
    }
    return _box;
  }

  Future<void> insertData(Repository repository) async {
    final repositoryBox = await box;
    await repositoryBox.put(repository.id.toString(), repository.toMap());
  }

  Future<void> deleteData(int id) async {
    final repositoryBox = await box;
    await repositoryBox.delete(id.toString());
  }

  Future<List<Repository>> getAllData() async {
    final repositoryBox = await box;
    return repositoryBox.values.map((map) {
      // Convert the dynamic map to Map<String, dynamic>
      final Map<String, dynamic> repoMap = Map<String, dynamic>.from(map as Map);

      return Repository(
        id: repoMap['id'] ?? 0,
        fullName: repoMap['fullName'] ?? '',
        private: repoMap['private'] ?? false,
        login: repoMap['login'] ?? '',
        avatar_url: repoMap['avatar_url'] ?? '',
        type: repoMap['type'] ?? '',
        description: repoMap['description'] ?? '',
      );
    }).toList();
  }
}