import 'package:backcountry_plan/models.dart';
import 'package:backcountry_plan/problem.dart';
import 'package:flutter/material.dart';

class PlanSummary extends StatelessWidget {
  final PlanModel plan;
  final Function(BuildContext) onNavigateToPlan;

  PlanSummary({@required this.plan, @required this.onNavigateToPlan});

  @override
  Widget build(BuildContext context) {
    if (plan == null) {
      return ElevatedButton(
        onPressed: () {
          onNavigateToPlan(context);
        },
        child: Text('Create plan'),
      );
    }
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('Key Message:'),
            subtitle: Text(plan.keyMessage),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              onNavigateToPlan(context);
            },
          ),
        ],
      ),
    );
  }
}

class PlanPage extends StatelessWidget {
  final PlanModel plan;

  PlanPage({Key key, @required this.plan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Plan"),
      ),
      body: PlanForm(plan: plan),
    );
  }
}

class PlanForm extends StatefulWidget {
  final PlanModel plan;

  PlanForm({@required this.plan}) : super();

  @override
  State<StatefulWidget> createState() => PlanFormState(plan: plan);
}

class PlanFormState extends State<PlanForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController keyMessageController = TextEditingController();
  final PlanModel plan;
  List<AvalancheProblemModel> problems = [];

  PlanFormState({@required this.plan}) : super();

  @override
  void initState() {
    if (plan.keyMessage.isNotEmpty) {
      keyMessageController.text = plan.keyMessage;
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

  @override
  Widget build(BuildContext context) {
    var problemTiles = problems.map((p) => ListTile(
          title: Text(p.problemType),
          subtitle: Text(p.size.toString()),
          trailing: Icon(Icons.chevron_right),
          onTap: () => _onEditProblem(context, p),
        ));

    return Form(
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
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            ...problemTiles,
            ElevatedButton(
              onPressed: () => _onAddProblem(context),
              child: Text('Add problem'),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState.validate()) {
                        plan.keyMessage = keyMessageController.text;
                        Navigator.pop(context, plan);
                      }
                    },
                    child: Text('Save Plan'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
