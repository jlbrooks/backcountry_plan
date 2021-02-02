import 'package:backcountry_plan/models.dart';
import 'package:backcountry_plan/common.dart';
import 'package:flutter/material.dart';

class ProblemEditPage extends StatefulWidget {
  final AvalancheProblemModel problem;

  ProblemEditPage({@required this.problem});

  @override
  State<StatefulWidget> createState() => ProblemEditPageState(problem: problem);
}

class ProblemEditPageState extends State<ProblemEditPage> {
  final AvalancheProblemModel problem;
  final TextEditingController _terrainFeaturesController =
      TextEditingController();
  final TextEditingController _dangerTrendController = TextEditingController();
  RangeValues problemSizeValues = RangeValues(0, 4);

  ProblemEditPageState({@required this.problem});

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

  ProblemLikelihoodInput({Key key, @required this.likelihood})
      : super(key: key);

  @override
  _ProblemLikelihoodInputState createState() =>
      _ProblemLikelihoodInputState(likelihood: likelihood);
}

class _ProblemLikelihoodInputState extends State<ProblemLikelihoodInput> {
  final ProblemLikelihood likelihood;

  _ProblemLikelihoodInputState({@required this.likelihood});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Slider(
        value: likelihood.likelihood.index.toDouble(),
        min: 0,
        max: (LikelihoodType.values.length - 1).toDouble(),
        divisions: (LikelihoodType.values.length - 1),
        label: likelihood.likelihood.toName(),
        onChanged: (value) {
          setState(() {
            likelihood.set(LikelihoodType.values[value.round()]);
          });
        },
      ),
    );
  }
}

class ProblemAspectInput extends StatefulWidget {
  final ProblemAspect aspects;
  ProblemAspectInput({Key key, @required this.aspects}) : super(key: key);

  @override
  _ProblemAspectInputState createState() =>
      _ProblemAspectInputState(aspects: aspects);
}

class _ProblemAspectInputState extends State<ProblemAspectInput> {
  final ProblemAspect aspects;

  _ProblemAspectInputState({@required this.aspects});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: AspectType.values
            .map((e) => CheckboxListTile(
                  title: Text(e.toName()),
                  value: aspects.isActive(e),
                  onChanged: (value) {
                    setState(() {
                      aspects.toggle(e);
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}

class ProblemElevationInput extends StatefulWidget {
  final ProblemElevation elevation;
  ProblemElevationInput({Key key, @required this.elevation}) : super(key: key);

  @override
  _ProblemElevationInputState createState() =>
      _ProblemElevationInputState(elevation: elevation);
}

class _ProblemElevationInputState extends State<ProblemElevationInput> {
  final ProblemElevation elevation;

  _ProblemElevationInputState({@required this.elevation});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: ElevationType.values
            .map((e) => CheckboxListTile(
                  title: Text(e.toName()),
                  value: elevation.isActive(e),
                  onChanged: (value) {
                    setState(() {
                      elevation.toggle(e);
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}

class ProblemSizeInput extends StatelessWidget {
  const ProblemSizeInput({
    Key key,
    @required this.problemSizeValues,
    @required this.onChanged,
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
  const ProblemTypeInput({Key key, @required this.problemType})
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
        onChanged: (ProblemType newValue) {
          setState(() {
            widget.problemType.set(newValue);
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
