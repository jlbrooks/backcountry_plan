import 'dart:math' as math;

import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/components/common.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';

class ProblemEditPage extends StatefulWidget {
  final AvalancheProblemModel problem;

  ProblemEditPage({required this.problem});

  @override
  State<StatefulWidget> createState() => ProblemEditPageState(problem: problem);
}

class ProblemEditPageState extends State<ProblemEditPage> {
  final AvalancheProblemModel problem;
  final TextEditingController _terrainFeaturesController =
      TextEditingController();
  final TextEditingController _dangerTrendController = TextEditingController();
  RangeValues problemSizeValues = RangeValues(0, 4);

  ProblemEditPageState({required this.problem});

  @override
  void initState() {
    super.initState();
    _terrainFeaturesController.text = problem.terrainFeatures;
    _dangerTrendController.text = problem.dangerTrendTiming;
    problemSizeValues = RangeValues(
        problem.size.startSize.toDouble(), problem.size.endSize.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit avalanche problem"),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context, problem);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionText(text: "Problem type:"),
                ProblemTypeInput(problemType: problem.problemType),
                const SizedBox(height: 20),
                SectionText(text: "Problem size:"),
                const SizedBox(height: 10),
                ProblemSizeInput(
                  problemSizeValues: problemSizeValues,
                  onChanged: (values) {
                    setState(() {
                      problemSizeValues = values;
                      problem.size
                          .update(values.start.round(), values.end.round());
                    });
                  },
                ),
                SectionText(text: "Problem likelihood:"),
                ProblemLikelihoodInput(likelihood: problem.likelihood),
                const SizedBox(height: 20),
                SectionText(text: "Problem elevation:"),
                ProblemElevationInput(elevation: problem.elevation),
                SectionText(text: "Problem aspects:"),
                ProblemAspectInput(aspects: problem.aspect),
                const SizedBox(height: 10),
                SectionText(text: "Terrain features:"),
                const SizedBox(height: 10),
                TextField(
                  controller: _terrainFeaturesController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText:
                        'Which features are of primary concern for this problem?',
                  ),
                  onChanged: (value) {
                    setState(() {
                      problem.terrainFeatures = _terrainFeaturesController.text;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SectionText(text: "Danger trend and timing:"),
                const SizedBox(height: 10),
                TextField(
                  controller: _dangerTrendController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What's the danger trend throughout the day?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      problem.dangerTrendTiming = _dangerTrendController.text;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProblemLikelihoodInput extends StatefulWidget {
  final ProblemLikelihood likelihood;
  final bool isEnabled;

  ProblemLikelihoodInput(
      {Key? key, required this.likelihood, this.isEnabled = true})
      : super(key: key);

  @override
  _ProblemLikelihoodInputState createState() => _ProblemLikelihoodInputState();
}

class _ProblemLikelihoodInputState extends State<ProblemLikelihoodInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RotatedBox(
        quarterTurns: 3,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.never,
            activeTrackColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
            activeTickMarkColor: Colors.grey,
            thumbColor: Colors.black,
            tickMarkShape: LineSliderTickShape(width: 10),
            thumbShape: LineSliderThumbPoint(
              width: 20,
              valueStrings:
                  LikelihoodType.values.map((e) => e.toName()).toList(),
            ),
          ),
          child: Slider(
            value: widget.likelihood.likelihood.index.toDouble(),
            min: 0,
            max: (LikelihoodType.values.length - 1).toDouble(),
            divisions: (LikelihoodType.values.length - 1),
            label: widget.likelihood.likelihood.toName(),
            onChanged: (value) {
              if (widget.isEnabled) {
                setState(() {
                  widget.likelihood.set(LikelihoodType.values[value.round()]);
                });
              }
            },
          ),
        ),
      ),
    );
  }
}

class LineSliderTickShape extends SliderTickMarkShape {
  final double width;

  const LineSliderTickShape({required this.width});

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    return Size.fromWidth(width);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {Animation<double>? activationAnimation,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required Offset thumbCenter,
      bool isEnabled = false}) {
    final Canvas canvas = context.canvas;

    /* Paint the line */
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startX = center.dx;
    final startY = center.dy - (width / 2);
    final endX = center.dx;
    final endY = center.dy + (width / 2);
    var path = Path();
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
    canvas.drawPath(path, paint);
  }
}

class LineSliderThumbPoint extends SliderComponentShape {
  final double min;
  final double max;
  final double width;
  final List<String> valueStrings;

  const LineSliderThumbPoint({
    required this.width,
    required this.valueStrings,
    this.min = 0,
    this.max = 4,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromWidth(width);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {required Animation<double> activationAnimation,
      required Animation<double> enableAnimation,
      required bool isDiscrete,
      required TextPainter labelPainter,
      required RenderBox parentBox,
      required SliderThemeData sliderTheme,
      required TextDirection textDirection,
      required double value,
      required double textScaleFactor,
      required Size sizeWithOverflow}) {
    final Canvas canvas = context.canvas;

    /* Paint the line */
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startX = center.dx;
    final startY = center.dy - (width / 2);
    final endX = center.dx;
    final endY = center.dy + (width / 2);
    var path = Path();
    path.moveTo(startX, startY);
    path.lineTo(endX, endY);
    canvas.drawPath(path, paint);

    //canvas.drawCircle(center, 2, paint);

    /* Paint the text */
    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor,
      ),
      text: getValueString(value),
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(center.dx + (tp.height / 2), center.dy + width);

    canvas.save();
    canvas.translate(textCenter.dx, textCenter.dy);
    canvas.rotate(1 / 2 * math.pi);

    tp.paint(canvas, new Offset(0.0, 0.0));
    canvas.restore();
  }

  String getValueString(double value) {
    return valueStrings[(min + (max - min) * value).round()];
  }
}

// class ProblemAspectInput extends StatefulWidget {
//   final ProblemAspect aspects;
//   ProblemAspectInput({Key? key, required this.aspects}) : super(key: key);

//   @override
//   _ProblemAspectInputState createState() =>
//       _ProblemAspectInputState(aspects: aspects);
// }

// class _ProblemAspectInputState extends State<ProblemAspectInput> {
//   final ProblemAspect aspects;

//   _ProblemAspectInputState({required this.aspects});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: AspectType.values
//             .map((e) => CheckboxListTile(
//                   title: Text(e.toName()),
//                   value: aspects.isActive(e),
//                   onChanged: (value) {
//                     setState(() {
//                       aspects.toggle(e);
//                     });
//                   },
//                 ))
//             .toList(),
//       ),
//     );
//   }
// }

class ProblemAspectInput extends StatefulWidget {
  final ProblemAspect aspects;
  ProblemAspectInput({Key? key, required this.aspects}) : super(key: key);

  @override
  _ProblemAspectInputState createState() =>
      _ProblemAspectInputState(aspects: aspects);
}

class _ProblemAspectInputState extends State<ProblemAspectInput> {
  final ProblemAspect aspects;

  _ProblemAspectInputState({required this.aspects});

  _onToggle(AspectType e) {
    setState(() {
      aspects.toggle(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: 120,
        child: CanvasTouchDetector(
          gesturesToOverride: [GestureType.onTapDown],
          builder: (context) => CustomPaint(
            painter: AspectSelectorPainter(
              activeAspects: aspects.aspects,
              context: context,
              onToggle: _onToggle,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class AspectSelectorPainter extends CustomPainter {
  final BuildContext context;
  final List<AspectType> activeAspects;
  final Function(AspectType) onToggle;
  static final int sides = 8;
  static final double angle = (math.pi * 2) / sides;
  static final double startAngle = -(angle / 2);
  static final Map<AspectType, double> aspectStartAngles = {
    AspectType.east: startAngle,
    AspectType.southEast: startAngle + (1 * angle),
    AspectType.south: startAngle + (2 * angle),
    AspectType.southWest: startAngle + (3 * angle),
    AspectType.west: startAngle + (4 * angle),
    AspectType.northWest: startAngle + (5 * angle),
    AspectType.north: startAngle + (6 * angle),
    AspectType.northEast: startAngle + (7 * angle),
  };

  AspectSelectorPainter(
      {required this.activeAspects,
      required this.context,
      required this.onToggle});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double outerRadius = size.height / 2.5;
    double angle = ((math.pi * 2) / sides);

    var touchCanvas = TouchyCanvas(context, canvas);

    // Fill it out!
    var fillPaint = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 0
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var outlinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fill in active aspects
    for (final aspect in activeAspects) {
      var startAspectAngle = aspectStartAngles[aspect]!;
      var endAspectAngle = startAspectAngle + angle;

      double outerStartX = outerRadius * math.cos(startAspectAngle) + center.dx;
      double outerStartY = outerRadius * math.sin(startAspectAngle) + center.dy;
      double outerEndX = outerRadius * math.cos(endAspectAngle) + center.dx;
      double outerEndY = outerRadius * math.sin(endAspectAngle) + center.dy;

      var path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(outerStartX, outerStartY);
      path.lineTo(outerEndX, outerEndY);
      path.lineTo(center.dx, center.dy);
      path.close();
      canvas.drawPath(
        path,
        fillPaint,
      );
    }

    // Draw outline triangles for all aspects, along with touch handling
    for (final aspect in AspectType.values) {
      var startAspectAngle = aspectStartAngles[aspect]!;
      var endAspectAngle = startAspectAngle + angle;

      double outerStartX = outerRadius * math.cos(startAspectAngle) + center.dx;
      double outerStartY = outerRadius * math.sin(startAspectAngle) + center.dy;
      double outerEndX = outerRadius * math.cos(endAspectAngle) + center.dx;
      double outerEndY = outerRadius * math.sin(endAspectAngle) + center.dy;

      var path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(outerStartX, outerStartY);
      path.lineTo(outerEndX, outerEndY);
      path.lineTo(center.dx, center.dy);
      path.close();
      touchCanvas.drawPath(
        path,
        outlinePaint,
        onTapDown: (tapdetail) {
          onToggle(aspect);
        },
      );
    }

    // Draw labels
    double labelRadius = size.height / 2.2;

    for (int i = 0; i < sides; i++) {
      var angleOffset = (angle * i);
      double x = labelRadius * math.cos(angleOffset) + center.dx;
      double y = labelRadius * math.sin(angleOffset) + center.dy;
      var painter = _labelTextPainter(ProblemAspect.labels[i]);
      var labelOffset =
          Offset(x - (painter.width / 2), y - (painter.height / 2));
      painter.paint(canvas, labelOffset);
    }
  }

  TextPainter _labelTextPainter(String label) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 8,
    );
    final textSpan = TextSpan(
      text: label,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
    );

    return textPainter;
  }

  @override
  // TODO: Fix this to correctly compare, comparing the map instance does not work
  bool shouldRepaint(AspectSelectorPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(AspectSelectorPainter oldDelegate) => false;
}

class ProblemElevationInput extends StatefulWidget {
  final ProblemElevation elevation;
  ProblemElevationInput({Key? key, required this.elevation}) : super(key: key);

  @override
  _ProblemElevationInputState createState() =>
      _ProblemElevationInputState(elevation: elevation);
}

class _ProblemElevationInputState extends State<ProblemElevationInput> {
  final ProblemElevation elevation;

  _ProblemElevationInputState({required this.elevation});

  _onToggle(ElevationType e) {
    setState(() {
      elevation.toggle(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: 180,
        child: CanvasTouchDetector(
          gesturesToOverride: [GestureType.onTapDown],
          builder: (context) => CustomPaint(
            painter: ElevationSelectorPainter(
              elevation: elevation,
              context: context,
              onToggle: _onToggle,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class ElevationSelectorPainter extends CustomPainter {
  final BuildContext context;
  final ProblemElevation elevation;
  final Function(ElevationType) onToggle;
  static final int sides = 8;
  static final double angle = (math.pi * 2) / sides;
  static final double startAngle = -(angle / 2);
  static final Map<AspectType, double> aspectStartAngles = {
    AspectType.east: startAngle,
    AspectType.southEast: startAngle + (1 * angle),
    AspectType.south: startAngle + (2 * angle),
    AspectType.southWest: startAngle + (3 * angle),
    AspectType.west: startAngle + (4 * angle),
    AspectType.northWest: startAngle + (5 * angle),
    AspectType.north: startAngle + (6 * angle),
    AspectType.northEast: startAngle + (7 * angle),
  };

  ElevationSelectorPainter(
      {required this.elevation, required this.context, required this.onToggle});

  @override
  void paint(Canvas canvas, Size size) {
    var touchCanvas = TouchyCanvas(context, canvas);

    var fillPaint = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var outlinePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Parameters
    var topLen = size.height;
    var midLen = topLen / 3;
    var upperLen = topLen * 2 / 3;
    var startAngle = math.pi / 3;

    // Bottom points
    var centerX = size.width / 2;
    var bottomLX = centerX - (topLen / 2);
    var bottomRX = bottomLX + topLen;
    var bottomY = size.height;
    // Mid points
    var midLX = bottomLX + midLen * math.cos(startAngle);
    var midRX = bottomLX + topLen - (midLen * math.cos(startAngle));
    var midY = bottomY - midLen * math.sin(startAngle);
    // Upper points
    var upperLX = bottomLX + upperLen * math.cos(startAngle);
    var upperRX = bottomLX + topLen - (upperLen * math.cos(startAngle));
    var upperY = bottomY - upperLen * math.sin(startAngle);
    // Tippy top
    var topY = bottomY - topLen * math.sin(startAngle);

    // Draw below treeline
    var bottomPath = Path();
    bottomPath.moveTo(bottomLX, bottomY);
    bottomPath.lineTo(midLX, midY);
    bottomPath.lineTo(midRX, midY);
    bottomPath.lineTo(bottomRX, bottomY);
    bottomPath.close();

    if (elevation.isActive(ElevationType.belowTreeline)) {
      canvas.drawPath(bottomPath, fillPaint);
    }

    touchCanvas.drawPath(
      bottomPath,
      outlinePaint,
      onTapDown: (tapDetail) {
        onToggle(ElevationType.belowTreeline);
      },
    );

    // Draw at treeline
    var midPath = Path();
    midPath.moveTo(midLX, midY);
    midPath.lineTo(upperLX, upperY);
    midPath.lineTo(upperRX, upperY);
    midPath.lineTo(midRX, midY);
    midPath.close();

    if (elevation.isActive(ElevationType.nearTreeline)) {
      canvas.drawPath(midPath, fillPaint);
    }

    touchCanvas.drawPath(
      midPath,
      outlinePaint,
      onTapDown: (tapDetail) {
        onToggle(ElevationType.nearTreeline);
      },
    );

    // Draw above treeline
    var upperPath = Path();
    upperPath.moveTo(upperLX, upperY);
    upperPath.lineTo(centerX, topY);
    upperPath.lineTo(upperRX, upperY);
    upperPath.close();

    if (elevation.isActive(ElevationType.aboveTreeline)) {
      canvas.drawPath(upperPath, fillPaint);
    }

    touchCanvas.drawPath(
      upperPath,
      outlinePaint,
      onTapDown: (tapDetail) {
        onToggle(ElevationType.aboveTreeline);
      },
    );

    // Draw labels
    var belowLabelX = (midLX - bottomLX) / 2;
    var belowLabelY = bottomY - ((bottomY - midY + 10) / 2);
    var bottomPainter = _labelTextPainter(ElevationType.belowTreeline.toName());
    var belowOffset = Offset(belowLabelX, belowLabelY);
    bottomPainter.paint(canvas, belowOffset);

    var midLabelX = ((upperLX - bottomLX) / 2) + belowLabelX;
    var midLabelY =
        bottomY - (((bottomY - upperY) / 2) + 10 + (bottomY - belowLabelY));
    var midPainter = _labelTextPainter(ElevationType.nearTreeline.toName());
    var midOffset = Offset(midLabelX, midLabelY);
    midPainter.paint(canvas, midOffset);

    var upperLabelX = ((upperLX - bottomLX) / 2) + midLabelX;
    var upperLabelY =
        bottomY - (((bottomY - upperY) / 2) + (bottomY - midLabelY));
    var upperPainter = _labelTextPainter(ElevationType.aboveTreeline.toName());
    var upperOffset = Offset(upperLabelX, upperLabelY);
    upperPainter.paint(canvas, upperOffset);
  }

  TextPainter _labelTextPainter(String label) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );
    final textSpan = TextSpan(
      text: label,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
    );

    return textPainter;
  }

  @override
  bool shouldRepaint(ElevationSelectorPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(ElevationSelectorPainter oldDelegate) => false;
}

class ProblemSizeInput extends StatelessWidget {
  const ProblemSizeInput({
    Key? key,
    required this.problemSizeValues,
    required this.onChanged,
  }) : super(key: key);

  final RangeValues problemSizeValues;
  final Function(RangeValues) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            showValueIndicator: ShowValueIndicator.always,
          ),
          child: RangeSlider(
            values: problemSizeValues,
            min: 0,
            max: 4,
            divisions: 4,
            labels: RangeLabels(
              AvalancheProblemSize
                  .problemSizes[problemSizeValues.start.round()],
              AvalancheProblemSize.problemSizes[problemSizeValues.end.round()],
            ),
            onChanged: (values) => onChanged(values),
          ),
        ),
      ],
    );
  }
}

class ProblemTypeInput extends StatefulWidget {
  final AvalancheProblemType problemType;
  const ProblemTypeInput({Key? key, required this.problemType})
      : super(key: key);

  @override
  _ProblemTypeInputState createState() => _ProblemTypeInputState();
}

class _ProblemTypeInputState extends State<ProblemTypeInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<ProblemType>(
        value: widget.problemType.type,
        hint: Text('Problem type'),
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (ProblemType? newValue) {
          setState(() {
            if (newValue != null) {
              widget.problemType.set(newValue);
            }
          });
        },
        items: ProblemType.values
            .map<DropdownMenuItem<ProblemType>>((ProblemType value) {
          return DropdownMenuItem<ProblemType>(
            value: value,
            child: Text(value.toName()),
          );
        }).toList(),
      ),
    );
  }
}
