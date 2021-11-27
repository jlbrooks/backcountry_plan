import 'package:backcountry_plan/db.dart';
import 'package:sembast/sembast.dart';

class SettingsModel {
  String trackerMapUrl;

  SettingsModel({required this.trackerMapUrl});

  SettingsModel.create() : this.trackerMapUrl = "";

  SettingsModel.fromMap(Map<String, dynamic> map) : this.trackerMapUrl = map['trackerMapUrl'] ?? "";

  Map<String, dynamic> toMap() {
    return {
      'trackerMapUrl': trackerMapUrl,
    };
  }
}

class SettingsStore {
  static final String storeKey = "settings";
  static final String recordKey = "user";
  static late StoreRef<String, Map<String, Object?>> store;

  static final SettingsStore _singleton = SettingsStore._internal();

  factory SettingsStore() {
    return _singleton;
  }

  SettingsStore._internal() {
    store = stringMapStoreFactory.store(SettingsStore.storeKey);
  }

  Future<SettingsModel> getOrCreate() async {
    var db = await JsonDatabaseManager.instance.database;

    var record = store.record(recordKey);
    var result = await record.get(db);

    if (result == null) {
      return SettingsModel.create();
    } else {
      return SettingsModel.fromMap(result);
    }
  }

  Future<SettingsModel> save(SettingsModel settings) async {
    var db = await JsonDatabaseManager.instance.database;

    await store.record(recordKey).put(db, settings.toMap());

    return settings;
  }
}
