import 'package:backcountry_plan/models/settings.dart';
import 'package:flutter/material.dart';
import 'package:backcountry_plan/components/screens.dart';
import 'package:backcountry_plan/components/common.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController trackerMapUrlController = TextEditingController();
  SettingsModel settings = SettingsModel.create();

  @override
  void initState() {
    super.initState();

    SettingsStore().getOrCreate().then((value) {
      setState(() {
        settings = value;
        trackerMapUrlController.text = settings.trackerMapUrl;
      });
    });
  }

  bool isSettingsUpdated() {
    return settings.trackerMapUrl != trackerMapUrlController.text;
  }

  void _onSave(BuildContext context) {
    settings.trackerMapUrl = trackerMapUrlController.text;
    SettingsStore().save(settings);
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    // Only ask to confirm changes if there have been any
    if (isSettingsUpdated()) {
      var result = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Discard changes?'),
            content: Text('Any changes that you have made on this page will be lost.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Discard changes')),
            ],
          );
        },
      );
      return (result != null && result);
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormListScreen(
      titleText: 'Settings',
      actionText: 'Save',
      onAction: _onSave,
      onWillPop: _onWillPop,
      formKey: formKey,
      children: [
        TextInputTitledSection(
          title: 'Map tracker url',
          subTitle: 'Permanent link to your personal map with tracking information. Used when sharing your trip information with a contact.',
          textCapitalization: TextCapitalization.none,
          keyboardType: TextInputType.url,
          hintText: 'https://garmin.com/foo',
          controller: trackerMapUrlController,
        )
      ],
    );
  }
}
