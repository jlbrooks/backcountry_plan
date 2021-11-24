import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:flutter/material.dart';

class CheckinPointListItem extends StatelessWidget {
  final CheckinPointModel point;
  final Function(BuildContext, CheckinPointModel) onTapped;

  const CheckinPointListItem({Key? key, required this.point, required this.onTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(point.description),
        subtitle: Text(point.time.format(context)),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          onTapped(context, point);
        },
      ),
    );
  }
}

class TerrainMindsetInput extends StatefulWidget {
  final TerrainMindset mindset;
  const TerrainMindsetInput({Key? key, required this.mindset}) : super(key: key);

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
        style: TextStyle(color: Colors.black),
        underline: Container(
          height: 2,
          color: Colors.blueAccent,
        ),
        onChanged: (MindsetType? newValue) {
          if (newValue != null) {
            setState(() {
              widget.mindset.set(newValue);
            });
          }
        },
        items: MindsetType.values.map<DropdownMenuItem<MindsetType>>((MindsetType value) {
          return DropdownMenuItem<MindsetType>(
            value: value,
            child: Text(value.toName()),
          );
        }).toList(),
      ),
    );
  }
}
