import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:backcountry_plan/db.dart';
import 'package:backcountry_plan/models/base.dart';
import 'package:backcountry_plan/models/plan.dart';

class AvalancheProblemModel extends BaseModel {
  AvalancheProblemType problemType;
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
      AvalancheProblemType problemType,
      AvalancheProblemSize size,
      ProblemElevation elevation,
      ProblemAspect aspect,
      ProblemLikelihood likelihood,
      this.terrainFeatures,
      this.dangerTrendTiming,
      this.notes,
      this.planId})
      : this.problemType = problemType ?? AvalancheProblemType(),
        this.size = size ?? AvalancheProblemSize(),
        this.elevation = elevation ?? ProblemElevation(),
        this.aspect = aspect ?? ProblemAspect(),
        this.likelihood = likelihood ?? ProblemLikelihood(),
        super(id: id);

  AvalancheProblemModel.newForPlan(int planId)
      : this.problemType = AvalancheProblemType(),
        this.size = AvalancheProblemSize(),
        this.elevation = ProblemElevation(),
        this.aspect = ProblemAspect(),
        this.likelihood = ProblemLikelihood(),
        this.terrainFeatures = "",
        this.dangerTrendTiming = "",
        this.notes = "",
        this.planId = planId;
}

class AvalancheProblemModelProvider
    extends BaseProvider<AvalancheProblemModel> {
  static final String problemTableName = "avalanche_problem";
  static final String problemColumnId = "id";
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
    problemColumnId,
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
                                        CREATE TABLE $problemTableName (
                                          $problemColumnId INTEGER PRIMARY KEY,
                                          $_columnProblemType TEXT,
                                          $_columnSize TEXT,
                                          $_columnElevation TEXT,
                                          $_columnAspect TEXT,
                                          $_columnLikelihood TEXT,
                                          $_columnTerrainFeatures TEXT,
                                          $_columnDangerTrendTiming TEXT,
                                          $_columnNotes TEXT,
                                          $_columnPlanId INTEGER,
                                          FOREIGN KEY ($_columnPlanId) REFERENCES ${PlanModelProvider.planTableName}(${PlanModelProvider.planColumnId})
                                        )
                                        ''';

  static final AvalancheProblemModelProvider _singleton =
      AvalancheProblemModelProvider._internal();

  factory AvalancheProblemModelProvider() {
    return _singleton;
  }

  AvalancheProblemModelProvider._internal() {
    tableName = problemTableName;
    columnId = problemColumnId;
    columns = _columns;
  }

  Map<String, dynamic> toMap(AvalancheProblemModel problem) {
    var map = <String, dynamic>{
      _columnPlanId: problem.planId,
      _columnProblemType: problem.problemType.serialize(),
      _columnSize: problem.size.serialize(),
      _columnElevation: problem.elevation.serialize(),
      _columnAspect: problem.aspect.serialize(),
      _columnLikelihood: problem.likelihood.serialize(),
      _columnTerrainFeatures: problem.terrainFeatures,
      _columnDangerTrendTiming: problem.dangerTrendTiming,
      _columnNotes: problem.notes
    };

    if (problem.id != null) {
      map[columnId] = problem.id;
    }

    return map;
  }

  AvalancheProblemModel fromMap(Map e) {
    return AvalancheProblemModel(
      id: e[columnId],
      problemType: AvalancheProblemType.deserialize(e[_columnProblemType]),
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

  ProblemLikelihood.fromLikelihood(this.likelihood);

  ProblemLikelihood() : this.likelihood = LikelihoodType.unlikely;

  static ProblemLikelihood deserialize(String s) {
    if (s.isNotEmpty) {
      return ProblemLikelihood.fromLikelihood(
          LikelihoodType.values[int.parse(s)]);
    }

    return ProblemLikelihood();
  }

  String serialize() {
    return likelihood.index.toString();
  }

  void set(LikelihoodType value) {
    likelihood = value;
  }

  @override
  String toString() {
    return likelihood.toName();
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

  ProblemElevation() : this.activeElevations = _defaultActiveElevations();

  ProblemElevation.fromList(List<ElevationType> activeElevationList)
      : this.activeElevations = parseList(activeElevationList);

  static Map<ElevationType, bool> parseList(List<ElevationType> l) {
    var map = _defaultActiveElevations();
    for (var e in l) {
      map[e] = true;
    }
    return map;
  }

  static Map<ElevationType, bool> _defaultActiveElevations() {
    return Map.fromIterables(
      ElevationType.values,
      ElevationType.values.map((e) => false),
    );
  }

  static ProblemElevation deserialize(String s) {
    if (s.isNotEmpty) {
      return ProblemElevation.fromList(
          s.split(',').map((e) => ElevationType.values[int.parse(e)]).toList());
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

  static final List<String> labels = [
    'E',
    'SE',
    'S',
    'SW',
    'W',
    'NW',
    'N',
    'NE'
  ];

  List<AspectType> get aspects =>
      activeAspects.keys.where((e) => activeAspects[e]).toList();
  Map<AspectType, bool> activeAspects;

  ProblemAspect.fromList(List<AspectType> activeAspectList)
      : this.activeAspects = parseList(activeAspectList);

  ProblemAspect() : this.activeAspects = defaultActiveAspects();

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
      return ProblemAspect.fromList(
          s.split(',').map((e) => AspectType.values[int.parse(e)]).toList());
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

enum ProblemType {
  dryLoose,
  stormSlab,
  windSlab,
  cornice,
  wetLoose,
  wetSlab,
  persistentSlab,
  deepSlab,
  glide
}

extension ProblemTypeHelpers on ProblemType {
  String toName() => AvalancheProblemType.problemTypeNames[this];
}

class AvalancheProblemType {
  static final Map<ProblemType, String> problemTypeNames = {
    ProblemType.dryLoose: 'Dry loose',
    ProblemType.stormSlab: 'Storm slab',
    ProblemType.windSlab: 'Wind slab',
    ProblemType.cornice: 'Cornice avalanche',
    ProblemType.wetLoose: 'Wet loose',
    ProblemType.wetSlab: 'Wet slab',
    ProblemType.persistentSlab: 'Persistent slab',
    ProblemType.deepSlab: 'Deep slab',
    ProblemType.glide: 'Glide avalanche'
  };

  ProblemType type;

  AvalancheProblemType.fromLikelihood(this.type);

  AvalancheProblemType() : this.type = ProblemType.dryLoose;

  static AvalancheProblemType deserialize(String s) {
    if (s.isNotEmpty) {
      return AvalancheProblemType.fromLikelihood(
          ProblemType.values[int.parse(s)]);
    }

    return AvalancheProblemType();
  }

  String serialize() {
    return type.index.toString();
  }

  void set(ProblemType value) {
    type = value;
  }

  @override
  String toString() {
    return type.toName();
  }
}