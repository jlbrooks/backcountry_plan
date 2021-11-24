import 'dart:core';

class AvalancheProblemModel {
  AvalancheProblemType problemType;
  AvalancheProblemSize size;
  ProblemElevation elevation;
  ProblemAspect aspect;
  ProblemLikelihood likelihood;
  String terrainFeatures;
  String dangerTrendTiming;
  String notes;

  AvalancheProblemModel({
    AvalancheProblemType? problemType,
    AvalancheProblemSize? size,
    ProblemElevation? elevation,
    ProblemAspect? aspect,
    ProblemLikelihood? likelihood,
    this.terrainFeatures = "",
    this.dangerTrendTiming = "",
    this.notes = "",
  })  : this.problemType = problemType ?? AvalancheProblemType(),
        this.size = size ?? AvalancheProblemSize(),
        this.elevation = elevation ?? ProblemElevation(),
        this.aspect = aspect ?? ProblemAspect(),
        this.likelihood = likelihood ?? ProblemLikelihood();

  AvalancheProblemModel.create()
      : this.problemType = AvalancheProblemType(),
        this.size = AvalancheProblemSize(),
        this.elevation = ProblemElevation(),
        this.aspect = ProblemAspect(),
        this.likelihood = ProblemLikelihood(),
        this.terrainFeatures = "",
        this.dangerTrendTiming = "",
        this.notes = "";

  AvalancheProblemModel.fromMap(Map<String, dynamic> map)
      : this.problemType = AvalancheProblemType.deserialize(map["problemType"]),
        this.size = AvalancheProblemSize.deserialize(map["size"]),
        this.elevation = ProblemElevation.deserialize(map["elevation"]),
        this.aspect = ProblemAspect.deserialize(map["aspect"]),
        this.likelihood = ProblemLikelihood.deserialize(map["likelihood"]),
        this.terrainFeatures = map["terrainFeatures"],
        this.dangerTrendTiming = map["dangerTrendTiming"],
        this.notes = map["notes"];

  Map<String, dynamic> toMap() {
    return {
      "problemType": this.problemType.serialize(),
      "size": this.size.serialize(),
      "elevation": this.elevation.serialize(),
      "aspect": this.aspect.serialize(),
      "likelihood": this.likelihood.serialize(),
      "terrainFeatures": this.terrainFeatures,
      "dangerTrendTiming": this.dangerTrendTiming,
      "notes": this.notes
    };
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

  static AvalancheProblemSize deserialize(String? s) {
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
  String toName() => ProblemLikelihood.problemLikelyhoodNames[this]!;
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
      return ProblemLikelihood.fromLikelihood(LikelihoodType.values[int.parse(s)]);
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
  String toName() => ProblemElevation.problemElevationNames[this]!;
}

class ProblemElevation {
  static final Map<ElevationType, String> problemElevationNames = {
    ElevationType.belowTreeline: 'Below treeline',
    ElevationType.nearTreeline: 'Near treeline',
    ElevationType.aboveTreeline: 'Above treeline'
  };

  List<ElevationType> get elevations => activeElevations.keys.where((e) => activeElevations[e]!).toList();
  Map<ElevationType, bool> activeElevations;

  ProblemElevation() : this.activeElevations = _defaultActiveElevations();

  ProblemElevation.fromList(List<ElevationType> activeElevationList) : this.activeElevations = parseList(activeElevationList);

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
      return ProblemElevation.fromList(s.split(',').map((e) => ElevationType.values[int.parse(e)]).toList());
    }

    return ProblemElevation();
  }

  String serialize() {
    return elevations.map((e) => e.index).join(",");
  }

  toggle(ElevationType e) {
    activeElevations[e] = !activeElevations[e]!;
  }

  bool isActive(ElevationType e) {
    return activeElevations[e]!;
  }
}

enum AspectType { north, northEast, east, southEast, south, southWest, west, northWest }

extension AspectTypeHelpers on AspectType {
  String toName() => ProblemAspect.problemAspectNames[this]!;
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

  static final List<String> labels = ['E', 'SE', 'S', 'SW', 'W', 'NW', 'N', 'NE'];

  List<AspectType> get aspects => activeAspects.keys.where((e) => activeAspects[e]!).toList();
  Map<AspectType, bool> activeAspects;

  ProblemAspect.fromList(List<AspectType> activeAspectList) : this.activeAspects = parseList(activeAspectList);

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
      return ProblemAspect.fromList(s.split(',').map((e) => AspectType.values[int.parse(e)]).toList());
    }

    return ProblemAspect();
  }

  String serialize() {
    return aspects.map((e) => e.index).join(",");
  }

  toggle(AspectType e) {
    activeAspects[e] = !activeAspects[e]!;
  }

  bool isActive(AspectType e) {
    return activeAspects[e]!;
  }

  bool operator ==(Object other) {
    print('checking');
    // if (identical(this, other)) {
    //   return true;
    // }
    print('here');

    if (other is! ProblemAspect) {
      return false;
    }

    // ignore: test_types_in_equals
    ProblemAspect otherAspect = other;

    for (var e in AspectType.values) {
      if (this.isActive(e) != otherAspect.isActive(e)) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => this.serialize().hashCode;
}

enum ProblemType { dryLoose, stormSlab, windSlab, cornice, wetLoose, wetSlab, persistentSlab, deepSlab, glide }

extension ProblemTypeHelpers on ProblemType {
  String toName() => AvalancheProblemType.problemTypeNames[this]!;
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
      return AvalancheProblemType.fromLikelihood(ProblemType.values[int.parse(s)]);
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
