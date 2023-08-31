import 'package:flutter/material.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String? label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  final List<MultiSelectDialogItem<V>>? items;
  final List<V>? initialSelectedValues;
  final Widget? title;
  final String? okButtonLabel;
  final String? cancelButtonLabel;
  final TextStyle labelStyle;
  final ShapeBorder? dialogShapeBorder;
  final Color? checkBoxCheckColor;
  final Color? checkBoxActiveColor;
  final bool showSelectAllButton;

  const MultiSelectDialog(
      {Key? key,
      required this.showSelectAllButton,
      this.items,
      this.initialSelectedValues,
      this.title,
      this.okButtonLabel,
      this.cancelButtonLabel,
      this.labelStyle = const TextStyle(),
      this.dialogShapeBorder,
      this.checkBoxActiveColor,
      this.checkBoxCheckColor})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = <V>[];

  @override
  void initState() {
    super.initState();
    if (widget.showSelectAllButton) {
      widget.items!
          // ignore: prefer_const_constructors
          .insert(0, MultiSelectDialogItem('all' as dynamic, 'Select All'));
    }
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues!);
      _handleSelectAll();
    }
  }

  void _onItemCheckedChange(MultiSelectDialogItem<V> item, bool? checked) {
    setState(() {
      if (item.value == 'all') {
        if (checked!) {
          _selectedValues.clear();
          for (var item in widget.items!) {
            _selectedValues.add(item.value);
          }
        } else {
          _selectedValues.clear();
        }
      } else {
        if (checked!) {
          _selectedValues.add(item.value);
        } else {
          _selectedValues.remove(item.value);
        }
      }
      _handleSelectAll();
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    _selectedValues.removeWhere((element) => element == 'all');
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      shape: widget.dialogShapeBorder,
      contentPadding: const EdgeInsets.only(top: 12.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: const EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
          child: ListBody(
            children: widget.items!.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(widget.cancelButtonLabel!),
          onPressed: _onCancelTap,
        ),
        TextButton(
          child: Text(widget.okButtonLabel!),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      checkColor: widget.checkBoxCheckColor,
      activeColor: widget.checkBoxActiveColor,
      title: Text(
        item.label!,
        style: widget.labelStyle,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item, checked),
    );
  }

  _handleSelectAll() {
    if (_selectedValues.where((element) => element != 'all').length ==
        widget.items!.length - 1) {
      _selectedValues.add(
          widget.items!.firstWhere((element) => element.value == 'all').value);
    } else {
      _selectedValues.removeWhere((element) => element == 'all');
    }
  }
}
