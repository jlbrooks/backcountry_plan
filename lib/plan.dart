import 'dart:io';
import 'dart:math' as math;

import 'package:backcountry_plan/models.dart';
import 'package:backcountry_plan/problem.dart';
import 'package:backcountry_plan/common.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  final PlanModel plan;

  PlanPage({@required this.plan}) : super();

  @override
  State<StatefulWidget> createState() => PlanPageState(plan: plan);
}

class PlanPageState extends State<PlanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController keyMessageController = TextEditingController();
  final TextEditingController forecastController = TextEditingController();
  final PlanModel plan;
  List<AvalancheProblemModel> problems = [];

  PlanPageState({@required this.plan}) : super();

  @override
  void initState() {
    if (plan.keyMessage.isNotEmpty) {
      keyMessageController.text = plan.keyMessage;
    }
    if (plan.forecast.isNotEmpty) {
      forecastController.text = plan.forecast;
    }
    AvalancheProblemModelProvider().getByPlanId(plan.id).then((_problems) {
      setState(() {
        problems = _problems;
      });
    });

    super.initState();
  }

  _onAddProblem(BuildContext context) async {
    var problem = AvalancheProblemModel.newForPlan(plan.id);
    final result = await Navigator.push<AvalancheProblemModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return ProblemEditPage(problem: problem);
      }),
    );

    if (result != null) {
      AvalancheProblemModelProvider().save(result);
      setState(() {
        problems.add(result);
      });
    }
  }

  _onEditProblem(BuildContext context, AvalancheProblemModel problem) async {
    final result = await Navigator.push<AvalancheProblemModel>(
      context,
      MaterialPageRoute(builder: (context) {
        return ProblemEditPage(problem: problem);
      }),
    );

    if (result != null) {
      AvalancheProblemModelProvider().save(result);
      setState(() {
        problems[problems.indexOf(result)] = result;
      });
    }
  }

  _onSave(BuildContext context) {
    // Validate will return true if the form is valid, or false if
    // the form is invalid.
    if (_formKey.currentState.validate()) {
      plan.keyMessage = keyMessageController.text;
      plan.forecast = forecastController.text;
      Navigator.pop(context, plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    var problemTiles = problems.map((p) {
      return Column(
        children: [
          ProblemSummary(problem: p),
          ListTile(
            title: Text(p.problemType.toString()),
            subtitle: Text(p.size.toString()),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _onEditProblem(context, p),
          ),
        ],
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Plan"),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _onSave(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: keyMessageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Key message',
                    hintText: 'Key message for the day',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: forecastController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Weather factors',
                    hintText: 'Current and forecast weather factors',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: null,
                ),
                const SizedBox(height: 20),
                SectionText(text: "Problems:"),
                ...problemTiles,
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _onAddProblem(context),
                  child: Text('Add problem'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProblemSummary extends StatelessWidget {
  final AvalancheProblemModel problem;

  const ProblemSummary({Key key, @required this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  problem.problemType.toString(),
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(problem.likelihood.likelihood.toName()),
                        Text('Likelihood')
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        AspectElevationDiagram(problem: problem),
                        Text('Aspect/elevation')
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(problem.size.toString()),
                        Text('Size'),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AspectElevationDiagram extends StatelessWidget {
  final AvalancheProblemModel problem;

  const AspectElevationDiagram({Key key, this.problem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: 120,
        child: CustomPaint(
          painter: AspectElevationPainter(
            problemAspect: problem.aspect,
            elevation: problem.elevation,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class AspectElevationPainter extends CustomPainter {
  final ProblemAspect problemAspect;
  final ProblemElevation elevation;
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

  AspectElevationPainter({this.problemAspect, this.elevation});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double outerRadius = size.height / 2.5;
    double middleRadius = size.height / 4;
    double innerRadius = size.height / 7;
    double angle = ((math.pi * 2) / sides);

    // Fill it out!
    var fillPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (final activeAspect in problemAspect.aspects) {
      stderr.writeln('Drawing ${activeAspect.toName()}');
      var startAspectAngle = aspectStartAngles[activeAspect];
      var endAspectAngle = startAspectAngle + angle;

      double innerStartX, innerStartY, innerEndX, innerEndY, shadeRadius;

      // Find start/end inner points
      if (elevation.elevations.contains(ElevationType.aboveTreeline)) {
        innerStartX = center.dx;
        innerStartY = center.dy;

        innerEndX = center.dx;
        innerEndY = center.dy;
      } else if (elevation.elevations.contains(ElevationType.nearTreeline)) {
        innerStartX = innerRadius * math.cos(startAspectAngle) + center.dx;
        innerStartY = innerRadius * math.sin(startAspectAngle) + center.dy;

        innerEndX = innerRadius * math.cos(endAspectAngle) + center.dx;
        innerEndY = innerRadius * math.sin(endAspectAngle) + center.dy;
      } else if (elevation.elevations.contains(ElevationType.belowTreeline)) {
        innerStartX = middleRadius * math.cos(startAspectAngle) + center.dx;
        innerStartY = middleRadius * math.sin(startAspectAngle) + center.dy;

        innerEndX = middleRadius * math.cos(endAspectAngle) + center.dx;
        innerEndY = middleRadius * math.sin(endAspectAngle) + center.dy;
      }

      // Find radius to use for outer points
      if (elevation.elevations.contains(ElevationType.belowTreeline)) {
        shadeRadius = outerRadius;
      } else if (elevation.elevations.contains(ElevationType.nearTreeline)) {
        shadeRadius = middleRadius;
      } else if (elevation.elevations.contains(ElevationType.aboveTreeline)) {
        shadeRadius = innerRadius;
      }

      double outerStartX = shadeRadius * math.cos(startAspectAngle) + center.dx;
      double outerStartY = shadeRadius * math.sin(startAspectAngle) + center.dy;
      double outerEndX = shadeRadius * math.cos(endAspectAngle) + center.dx;
      double outerEndY = shadeRadius * math.sin(endAspectAngle) + center.dy;

      var path = Path();
      path.moveTo(innerStartX, innerStartY);
      path.lineTo(outerStartX, outerStartY);
      path.lineTo(outerEndX, outerEndY);
      path.lineTo(innerEndX, innerEndY);
      path.close();
      canvas.drawPath(path, fillPaint);
    }

    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw octagons
    var outerOctagonPath = _polygonPath(sides, outerRadius, center, 2.0, true);
    canvas.drawPath(outerOctagonPath, paint);

    var middleOctagonPath =
        _polygonPath(sides, middleRadius, center, 2.0, false);
    canvas.drawPath(middleOctagonPath, paint);

    var innerOctagonPath = _polygonPath(sides, innerRadius, center, 2.0, false);
    canvas.drawPath(innerOctagonPath, paint);

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

  Path _polygonPath(
    int sides,
    double radius,
    Offset center,
    double rotateFactor,
    bool fill,
  ) {
    var path = Path();
    var angle = ((math.pi * 2) / sides);
    var angleStart = angle / rotateFactor;

    Offset startPoint = Offset(
      radius * math.cos(angleStart),
      radius * math.sin(angleStart),
    );

    path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

    for (int i = 0; i <= sides; i++) {
      var angleOffset = (angle * i) + angleStart;
      double x = radius * math.cos(angleOffset) + center.dx;
      double y = radius * math.sin(angleOffset) + center.dy;
      path.lineTo(x, y);

      if (fill && i < (sides / 2)) {
        double xCross = radius * -math.cos(angleOffset) + center.dx;
        double yCross = radius * -math.sin(angleOffset) + center.dy;
        path.lineTo(xCross, yCross);
        path.lineTo(x, y);
      }
    }
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(AspectElevationPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(AspectElevationPainter oldDelegate) => false;
}
