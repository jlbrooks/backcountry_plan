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
    var problemTiles = problems.map((p) => ListTile(
          title: Text(p.problemType),
          subtitle: Text(p.size.toString()),
          trailing: Icon(Icons.chevron_right),
          onTap: () => _onEditProblem(context, p),
        ));

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
