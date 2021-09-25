import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:backcountry_plan/common.dart';
import 'package:flutter/material.dart';

class TerrainPlanSummary extends StatelessWidget {
  final TerrainPlanModel plan;
  final Function(TerrainPlanModel) onTap;

  const TerrainPlanSummary({Key key, this.plan, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () => onTap(plan),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.mindset.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Turnaround time"),
                          Text(plan.turnaroundTime.format(context))
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Route",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      plan.route,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Areas to avoid",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      plan.areasToAvoid,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TerrainPlanEditPage extends StatefulWidget {
  final TerrainPlanModel terrainPlan;

  TerrainPlanEditPage({Key key, @required this.terrainPlan}) : super(key: key);

  @override
  _TerrainPlanEditPageState createState() => _TerrainPlanEditPageState();
}

class _TerrainPlanEditPageState extends State<TerrainPlanEditPage> {
  final TextEditingController routeController = TextEditingController();
  final TextEditingController areasToAvoidController = TextEditingController();
  final TextEditingController turnaroundPointController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    routeController.text = widget.terrainPlan.route;
    areasToAvoidController.text = widget.terrainPlan.areasToAvoid;
    turnaroundPointController.text = widget.terrainPlan.turnaroundPoint;
  }

  Future<void> _showTurnaroundTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.terrainPlan.turnaroundTime,
    );
    setState(() {
      widget.terrainPlan.turnaroundTime = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit terrain plan"),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context, widget.terrainPlan);
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
              children: [
                SectionText(text: "Terrain Mindset"),
                TerrainMindsetInput(mindset: widget.terrainPlan.mindset),
                const SizedBox(height: 20),
                SectionText(text: "Route"),
                const SizedBox(height: 10),
                TextField(
                  controller: routeController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 15,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What's your route?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.route = routeController.text;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SectionText(text: "Areas to avoid"),
                const SizedBox(height: 10),
                TextField(
                  controller: areasToAvoidController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 8,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What are the slopes and areas to avoid?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.areasToAvoid =
                          areasToAvoidController.text;
                    });
                  },
                ),
                const SizedBox(height: 10),
                SectionText(text: "Turnaround point and time"),
                const SizedBox(height: 10),
                TextField(
                  controller: turnaroundPointController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "What's the turnaround point?",
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.terrainPlan.turnaroundPoint =
                          turnaroundPointController.text;
                    });
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.terrainPlan.turnaroundTime.format(context),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showTurnaroundTimePicker(context),
                        child: Text('Change time'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TerrainMindsetInput extends StatefulWidget {
  final TerrainMindset mindset;
  const TerrainMindsetInput({Key key, @required this.mindset})
      : super(key: key);

  @override
  _TerrainMindsetInputState createState() => _TerrainMindsetInputState();
}

class _TerrainMindsetInputState extends State<TerrainMindsetInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButton<MindsetType>(
        value: widget.mindset.type,
        hint: Text('Mindset'),
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          color: Colors.deepPurpleAccent,
        ),
        onChanged: (MindsetType newValue) {
          setState(() {
            widget.mindset.set(newValue);
          });
        },
        items: MindsetType.values
            .map<DropdownMenuItem<MindsetType>>((MindsetType value) {
          return DropdownMenuItem<MindsetType>(
            value: value,
            child: Text(value.toName()),
          );
        }).toList(),
      ),
    );
  }
}
