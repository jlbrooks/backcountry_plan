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
    var problem = AvalancheProblemModel(planId: plan.id);
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
            title: Text(p.problemType),
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
      body: Form(
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
                  problem.problemType,
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
                        Text('Likelihood')
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
          painter: AspectElevationPainter(),
          child: Container(),
        ),
      ),
    );
  }
}

class AspectElevationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    const sides = 8;

    // Draw octagons
    double outerRadius = size.height / 2.5;
    double middleRadius = size.height / 4;
    double innerRadius = size.height / 7;
    var outerOctagonPath = _polygonPath(sides, outerRadius, center, 2.0, true);
    canvas.drawPath(outerOctagonPath, paint);

    var middleOctagonPath =
        _polygonPath(sides, middleRadius, center, 2.0, false);
    canvas.drawPath(middleOctagonPath, paint);

    var innerOctagonPath = _polygonPath(sides, innerRadius, center, 2.0, false);
    canvas.drawPath(innerOctagonPath, paint);

    // Draw labels
    double labelRadius = size.height / 2.2;
    var angle = ((math.pi * 2) / sides);

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

      if (i < (sides / 2)) {
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
