import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:flutter/material.dart';

class EditCheckinPointPage extends StatefulWidget {
  final CheckinPointModel checkinPoint;
  EditCheckinPointPage({Key? key, required this.checkinPoint}) : super(key: key);

  @override
  _EditCheckinPointPageState createState() => _EditCheckinPointPageState();
}

class _EditCheckinPointPageState extends State<EditCheckinPointPage> {
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    descriptionController.text = widget.checkinPoint.description;
  }

  _onSave(BuildContext context) {
    Navigator.pop(context, widget.checkinPoint);
  }

  Future<void> _showCheckinTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.checkinPoint.time,
    );
    if (picked != null) {
      setState(() {
        widget.checkinPoint.time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit checkin point"),
        actions: [
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _onSave(context),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.checkinPoint.time.format(context),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showCheckinTimePicker(context),
                      child: Text('Change time'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                  controller: descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Description',
                    hintText: 'Describe the checkin point',
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  onChanged: (value) {
                    setState(() {
                      widget.checkinPoint.description = descriptionController.text;
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
