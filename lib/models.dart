import 'dart:core';

import 'package:backcountry_plan/db.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseModel {
  int id;

  BaseModel({this.id});
}

abstract class BaseProvider<T extends BaseModel> {
  String tableName;
  String columnId;
  List<String> columns;

  Future save(T model) async {
    if (model.id == null) {
      model.id = await _insert(model);
    } else {
      _update(model);
    }
  }

  Future<int> _insert(T model) async {
    var db = await DatabaseManager.instance.database;
    int id = await db.insert(tableName, toMap(model));
    return id;
  }

  Future<int> _update(T model) async {
    var db = await DatabaseManager.instance.database;
    int id = await db.update(
      tableName,
      toMap(model),
      where: '$columnId = ?',
      whereArgs: [model.id],
    );

    return id;
  }

  Future<T> get(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return fromMap(maps.first);
    }
    return null;
  }

  Future<List<T>> all() async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
    );

    return maps.map((e) => fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(T trip);

  T fromMap(Map e);
}

class TripModelProvider extends BaseProvider<TripModel> {
  static final String _tableName = "backcountry_trip";
  static final String _columnId = "id";
  static final String _columnName = "name";
  static final List<String> _columns = [_columnId, _columnName];

  static final String createStatement = '''
                                        CREATE TABLE $_tableName (
                                          $_columnId INTEGER PRIMARY KEY,
                                          $_columnName TEXT
                                        )
                                        ''';

  static final TripModelProvider _singleton = TripModelProvider._internal();

  factory TripModelProvider() {
    return _singleton;
  }

  TripModelProvider._internal() {
    tableName = _tableName;
    columnId = _columnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(TripModel trip) {
    var map = <String, dynamic>{_columnName: trip.name};

    if (trip.id != null) {
      map[_columnId] = trip.id;
    }

    return map;
  }

  TripModel fromMap(Map e) {
    return TripModel(
      id: e[_columnId],
      name: e[_columnName],
    );
  }
}

class TripModel extends BaseModel {
  String name;
  int planId;
  PlanModel plan;

  TripModel({id, this.name, this.planId, this.plan}) : super(id: id);
}

class PlanModel extends BaseModel {
  String keyMessage;
  int tripId;

  PlanModel({id, this.keyMessage, this.tripId}) : super(id: id);
}

class PlanModelProvider extends BaseProvider<PlanModel> {
  static final String _tableName = "backcountry_plan";
  static final String _columnId = "id";
  static final String _columnKeyMessage = "key_message";
  static final String _columnTripId = "trip_id";
  static final List<String> _columns = [
    _columnId,
    _columnKeyMessage,
    _columnTripId
  ];

  static final String createStatement = '''
                                        CREATE TABLE $_tableName (
                                          $_columnId INTEGER PRIMARY KEY,
                                          $_columnKeyMessage TEXT,
                                          $_columnTripId INTEGER,
                                          FOREIGN KEY ($_columnTripId) REFERENCES ${TripModelProvider._tableName}(${TripModelProvider._columnId})
                                        )
                                        ''';

  static final PlanModelProvider _singleton = PlanModelProvider._internal();

  factory PlanModelProvider() {
    return _singleton;
  }

  PlanModelProvider._internal() {
    tableName = _tableName;
    columnId = _columnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(PlanModel plan) {
    var map = <String, dynamic>{
      _columnTripId: plan.tripId,
      _columnKeyMessage: plan.keyMessage
    };

    if (plan.id != null) {
      map[_columnId] = plan.id;
    }

    return map;
  }

  PlanModel fromMap(Map e) {
    return PlanModel(
      id: e[_columnId],
      keyMessage: e[_columnKeyMessage],
      tripId: e[_columnTripId],
    );
  }

  Future<PlanModel> getByTripId(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$_columnTripId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return fromMap(maps.first);
    }
    return null;
  }
}

class AvalancheProblemSize {
  static final List<String> problemSizes = [
    'D1',
    'D2',
    'D3',
    'D4',
    'D5',
  ];

  int startSize;
  int endSize;

  String get startSizeString => problemSizes[startSize];
  String get endSizeString => problemSizes[endSize];

  AvalancheProblemSize({this.startSize = 0, this.endSize = 4});

  @override
  String toString() {
    if (startSize == endSize) {
      return startSizeString;
    } else {
      return "$startSizeString-$endSizeString";
    }
  }

  String serialize() {
    return "$startSize-$endSize";
  }

  static AvalancheProblemSize deserialize(String s) {
    if (s != null) {
      var split = s.split("-");
      return AvalancheProblemSize(
        startSize: int.parse(split[0]),
        endSize: int.parse(split[1]),
      );
    }
    return AvalancheProblemSize();
  }

  void update(int start, int end) {
    startSize = start;
    endSize = end;
  }
}

enum LikelihoodType { unlikely, possible, likely, veryLikely, almostCertain }

extension LikelihoodTypeHelpers on LikelihoodType {
  String toName() => ProblemLikelihood.problemLikelyhoodNames[this];
}

class ProblemLikelihood {
  static final Map<LikelihoodType, String> problemLikelyhoodNames = {
    LikelihoodType.unlikely: 'Unlikely',
    LikelihoodType.possible: 'Possible',
    LikelihoodType.likely: 'Likely',
    LikelihoodType.veryLikely: 'Very Likely',
    LikelihoodType.almostCertain: 'Almost Certain'
  };

  LikelihoodType likelihood;

  ProblemLikelihood({likelihood})
      : this.likelihood = likelihood ?? LikelihoodType.unlikely;

  static ProblemLikelihood deserialize(String s) {
    if (s.isNotEmpty) {
      return ProblemLikelihood(likelihood: LikelihoodType.values[int.parse(s)]);
    }

    return ProblemLikelihood();
  }

  String serialize() {
    return likelihood.index.toString();
  }

  void set(LikelihoodType value) {
    likelihood = value;
  }
}

enum ElevationType { belowTreeline, nearTreeline, aboveTreeline }

extension ElevationTypeHelpers on ElevationType {
  String toName() => ProblemElevation.problemElevationNames[this];
}

class ProblemElevation {
  static final Map<ElevationType, String> problemElevationNames = {
    ElevationType.belowTreeline: 'Below treeline',
    ElevationType.nearTreeline: 'Near treeline',
    ElevationType.aboveTreeline: 'Above treeline'
  };

  List<ElevationType> get elevations =>
      activeElevations.keys.where((e) => activeElevations[e]).toList();
  Map<ElevationType, bool> activeElevations;

  ProblemElevation({List<ElevationType> activeElevationList})
      : this.activeElevations = (activeElevationList == null)
            ? defaultActiveElevations()
            : parseList(activeElevationList);

  static Map<ElevationType, bool> parseList(List<ElevationType> l) {
    var map = defaultActiveElevations();
    for (var e in l) {
      map[e] = true;
    }
    return map;
  }

  static Map<ElevationType, bool> defaultActiveElevations() {
    return Map.fromIterables(
      ElevationType.values,
      ElevationType.values.map((e) => false),
    );
  }

  static ProblemElevation deserialize(String s) {
    if (s.isNotEmpty) {
      return ProblemElevation(
          activeElevationList: s
              .split(',')
              .map((e) => ElevationType.values[int.parse(e)])
              .toList());
    }

    return ProblemElevation();
  }

  String serialize() {
    return elevations.map((e) => e.index).join(",");
  }

  toggle(ElevationType e) {
    activeElevations[e] = !activeElevations[e];
  }

  bool isActive(ElevationType e) {
    return activeElevations[e];
  }
}

enum AspectType {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest
}

extension AspectTypeHelpers on AspectType {
  String toName() => ProblemAspect.problemAspectNames[this];
}

class ProblemAspect {
  static final Map<AspectType, String> problemAspectNames = {
    AspectType.north: 'North',
    AspectType.northEast: 'Northeast',
    AspectType.east: 'East',
    AspectType.southEast: 'Southeast',
    AspectType.south: 'South',
    AspectType.southWest: 'Southwest',
    AspectType.west: 'West',
    AspectType.northWest: 'Northwest'
  };

  List<AspectType> get aspects =>
      activeAspects.keys.where((e) => activeAspects[e]).toList();
  Map<AspectType, bool> activeAspects;

  ProblemAspect({List<AspectType> activeAspectList})
      : this.activeAspects = (activeAspectList == null)
            ? defaultActiveAspects()
            : parseList(activeAspectList);

  static Map<AspectType, bool> parseList(List<AspectType> l) {
    var map = defaultActiveAspects();
    for (var e in l) {
      map[e] = true;
    }
    return map;
  }

  static Map<AspectType, bool> defaultActiveAspects() {
    return Map.fromIterables(
      AspectType.values,
      AspectType.values.map((e) => false),
    );
  }

  static ProblemAspect deserialize(String s) {
    if (s.isNotEmpty) {
      return ProblemAspect(
          activeAspectList: s
              .split(',')
              .map((e) => AspectType.values[int.parse(e)])
              .toList());
    }

    return ProblemAspect();
  }

  String serialize() {
    return aspects.map((e) => e.index).join(",");
  }

  toggle(AspectType e) {
    activeAspects[e] = !activeAspects[e];
  }

  bool isActive(AspectType e) {
    return activeAspects[e];
  }
}

class AvalancheProblemModel extends BaseModel {
  static final List<String> problemTypes = [
    'Dry loose',
    'Storm slab',
    'Wind slab',
    'Cornice avalanche',
    'Wet loose',
    'Wet slab',
    'Persistent slab',
    'Deep slab',
    'Glide avalanche'
  ];

  String problemType;
  AvalancheProblemSize size;
  ProblemElevation elevation;
  ProblemAspect aspect;
  ProblemLikelihood likelihood;
  String terrainFeatures;
  String dangerTrendTiming;
  String notes;

  int planId;

  AvalancheProblemModel(
      {id,
      this.problemType,
      size,
      elevation,
      aspect,
      likelihood,
      this.terrainFeatures,
      this.dangerTrendTiming,
      this.notes,
      this.planId})
      : this.size = size ?? AvalancheProblemSize(),
        this.elevation = elevation ?? ProblemElevation(),
        this.aspect = aspect ?? ProblemAspect(),
        this.likelihood = likelihood ?? ProblemLikelihood(),
        super(id: id);
}

class AvalancheProblemModelProvider
    extends BaseProvider<AvalancheProblemModel> {
  static final String _tableName = "avalanche_problem";
  static final String _columnId = "id";
  static final String _columnProblemType = "problem_type";
  static final String _columnSize = "size";
  static final String _columnElevation = "elevation";
  static final String _columnAspect = "aspect";
  static final String _columnLikelihood = "likelihood";
  static final String _columnTerrainFeatures = "terrain_features";
  static final String _columnDangerTrendTiming = "danger_trend_timing";
  static final String _columnNotes = "notes";
  static final String _columnPlanId = "plan_id";

  static final List<String> _columns = [
    _columnId,
    _columnProblemType,
    _columnSize,
    _columnElevation,
    _columnAspect,
    _columnLikelihood,
    _columnTerrainFeatures,
    _columnDangerTrendTiming,
    _columnNotes,
    _columnPlanId
  ];

  static final String createStatement = '''
                                        CREATE TABLE $_tableName (
                                          $_columnId INTEGER PRIMARY KEY,
                                          $_columnProblemType TEXT,
                                          $_columnSize TEXT,
                                          $_columnElevation TEXT,
                                          $_columnAspect TEXT,
                                          $_columnLikelihood TEXT,
                                          $_columnTerrainFeatures TEXT,
                                          $_columnDangerTrendTiming TEXT,
                                          $_columnNotes TEXT,
                                          $_columnPlanId INTEGER,
                                          FOREIGN KEY ($_columnPlanId) REFERENCES ${PlanModelProvider._tableName}(${PlanModelProvider._columnId})
                                        )
                                        ''';

  static final AvalancheProblemModelProvider _singleton =
      AvalancheProblemModelProvider._internal();

  factory AvalancheProblemModelProvider() {
    return _singleton;
  }

  AvalancheProblemModelProvider._internal() {
    tableName = _tableName;
    columnId = _columnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(AvalancheProblemModel problem) {
    var map = <String, dynamic>{
      _columnPlanId: problem.planId,
      _columnProblemType: problem.problemType,
      _columnSize: problem.size.serialize(),
      _columnElevation: problem.elevation.serialize(),
      _columnAspect: problem.aspect.serialize(),
      _columnLikelihood: problem.likelihood.serialize(),
      _columnTerrainFeatures: problem.terrainFeatures,
      _columnDangerTrendTiming: problem.dangerTrendTiming,
      _columnNotes: problem.notes
    };

    if (problem.id != null) {
      map[_columnId] = problem.id;
    }

    return map;
  }

  AvalancheProblemModel fromMap(Map e) {
    return AvalancheProblemModel(
      id: e[_columnId],
      problemType: e[_columnProblemType],
      size: AvalancheProblemSize.deserialize(e[_columnSize]),
      elevation: ProblemElevation.deserialize(e[_columnElevation]),
      aspect: ProblemAspect.deserialize(e[_columnAspect]),
      likelihood: ProblemLikelihood.deserialize(e[_columnLikelihood]),
      terrainFeatures: e[_columnTerrainFeatures],
      dangerTrendTiming: e[_columnDangerTrendTiming],
      notes: e[_columnNotes],
      planId: e[_columnPlanId],
    );
  }

  Future<List<AvalancheProblemModel>> getByPlanId(int id) async {
    Database db = await DatabaseManager.instance.database;
    List<Map> maps = await db.query(
      tableName,
      columns: columns,
      where: '$_columnPlanId = ?',
      whereArgs: [id],
    );
    return maps.map((e) => fromMap(e)).toList();
  }
}
