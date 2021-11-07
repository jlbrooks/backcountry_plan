import 'package:flutter/material.dart';

class FormColumnScreen extends StatelessWidget {
  final String titleText;
  final String actionText;
  final Function(BuildContext) onAction;
  final List<Widget> children;
  final GlobalKey<FormState> formKey;
  final Future<bool> Function()? onWillPop;
  final Widget? floatingActionButton;

  FormColumnScreen({
    Key? key,
    required this.titleText,
    required this.actionText,
    required this.onAction,
    required this.children,
    required this.formKey,
    this.onWillPop,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      titleText: titleText,
      actionText: actionText,
      onAction: onAction,
      onWillPop: onWillPop,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class BasicScreen extends StatelessWidget {
  final String titleText;
  final String actionText;
  final Function(BuildContext) onAction;
  final Widget? child;
  final Future<bool> Function()? onWillPop;
  final Widget? floatingActionButton;

  const BasicScreen({
    Key? key,
    required this.titleText,
    required this.actionText,
    required this.onAction,
    this.child,
    this.onWillPop,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? actionButton;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(titleText),
          actions: [
            TextButton(
              child: Text(
                actionText,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => onAction(context),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: child,
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}

class TextInputTitledSection extends StatelessWidget {
  final String title;
  final String? subTitle;
  final String hintText;
  // TODO: Make validation configurable?
  final String validationText;
  final Function(String)? onChanged;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const TextInputTitledSection({
    Key? key,
    required this.title,
    this.subTitle,
    required this.hintText,
    required this.validationText,
    required this.controller,
    this.onChanged,
    this.minLines = 1,
    this.maxLines = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TitledSection(
      title: title,
      subTitle: subTitle,
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationText;
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }
}

class TitledSection extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? child;
  const TitledSection({Key? key, required this.title, this.subTitle, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget subTitleSection = Container();
    if (subTitle != null) {
      subTitleSection = Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          subTitle!,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      );
    }
    List<Widget> children = [
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subTitleSection
    ];

    if (child != null) {
      children.add(child!);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
