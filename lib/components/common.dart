import 'package:flutter/material.dart';

class SectionText extends StatelessWidget {
  final String text;
  const SectionText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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

class DeleteableListView<T> extends StatelessWidget {
  final List<T> list;
  final String confirmDeleteTitle;
  final String Function(T) confirmDeleteBodyBuilder;
  final Function(T, int) onDelete;
  final Widget Function(T) itemBuilder;
  const DeleteableListView({
    Key? key,
    required this.list,
    required this.confirmDeleteTitle,
    required this.confirmDeleteBodyBuilder,
    required this.onDelete,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.list.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = this.list[index];
        return Dismissible(
          key: Key(item.hashCode.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(confirmDeleteTitle),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text(confirmDeleteBodyBuilder(item)),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) => onDelete(item, index),
          background: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: itemBuilder(item),
        );
      },
    );
  }
}
