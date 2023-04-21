import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';

import 'adaptive_items.dart';

class AdaptiveListTile extends StatelessWidget {
  final AdaptiveListItem item;

  const AdaptiveListTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      if (box.maxWidth < 600) {
        return AdaptiveListTileWidget(
            item: item,
            stateFactory: () {
              return MobileListTileState();
            });
      }
      return AdaptiveListTileWidget(
          item: item,
          stateFactory: () {
            return FullListTileState();
          });
    });
  }
}

class AdaptiveListTileWidget extends StatefulWidget {
  final ValueGetter<State<AdaptiveListTileWidget>> stateFactory;
  final AdaptiveListItem item;

  const AdaptiveListTileWidget(
      {Key? key, required this.item, required this.stateFactory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return stateFactory();
  }
}

class MobileListTileState extends State<AdaptiveListTileWidget> {
  @override
  Widget build(BuildContext context) {
    var actions =
        widget.item.contextualItems.whereType<AdaptiveItemAction>().toList();
    var toggles =
        widget.item.contextualItems.whereType<AdaptiveItemToggle>().toList();
    var buttons =
        widget.item.contextualItems.whereType<AdaptiveItemButton>().toList();
    actions.sort((a, b) => a.compareTo(b));
    toggles.sort((a, b) => a.compareTo(b));
    buttons.sort((a, b) => a.compareTo(b));
    var tile = Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.item.icon,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.title),
                if (widget.item.subtitle != null) Text(widget.item.subtitle!)
              ],
            ),
          ),
        ),
        actions.isEmpty
            ? const SizedBox()
            : IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: actions.map((action) {
                              return TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    action.onTap();
                                  },
                                  icon: action.icon,
                                  label: Text(action.label));
                            }).toList(),
                          ),
                      backgroundColor: Theme.of(context).secondaryHeaderColor);
                }),
      ],
    );
    if (toggles.isEmpty && buttons.isEmpty) {
      return Card(
        child: InkWell(onTap: widget.item.onPressed, child: tile),
        shape: widget.item.borderDecoration,
      );
    }
    return Card(
        shape: widget.item.borderDecoration,
        child: InkWell(
            onTap: widget.item.onPressed,
            child: Column(children: [
              tile,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonBar(
                      children: toggles.map((toggle) {
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(toggle.label),
                      Switch.adaptive(
                          value: toggle.switchNotifier.value,
                          onChanged: (value) {
                            setState(() {
                              toggle.switchNotifier.value = value;
                            });
                          })
                    ]);
                  }).toList()),
                  ButtonBar(
                      children: buttons.map((button) {
                    return roundEdgedButton(
                        buttonText: button.label, onPressed: button.onPressed);
                  }).toList()),
                ],
              )
            ])));
  }
}

class FullListTileState extends State<AdaptiveListTileWidget> {
  @override
  Widget build(BuildContext context) {
    var actionsAndTogglesAndButtons = widget.item.contextualItems.toList();
    actionsAndTogglesAndButtons.sort((a, b) => a.compareTo(b));
    return Card(
      shape: widget.item.borderDecoration,
      child: InkWell(
        onTap: widget.item.onPressed,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.item.icon,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.title),
                        if (widget.item.subtitle != null)
                          Text(widget.item.subtitle!)
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ButtonBar(
              children: actionsAndTogglesAndButtons.map((action) {
                if (action is AdaptiveItemAction) {
                  return AppButtonWithIcon(
                    icon: action.icon,
                    onPressed: action.onTap,
                    buttonText: action.label,
                  );
                } else if (action is AdaptiveItemToggle) {
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(action.label),
                    Switch.adaptive(
                        value: action.switchNotifier.value,
                        onChanged: (value) {
                          setState(() {
                            action.switchNotifier.value = value;
                          });
                        })
                  ]);
                } else if (action is AdaptiveItemButton) {
                  return AppButtonWithIcon(
                    icon: action.icon,
                    onPressed: action.onPressed,
                    buttonText: action.label,
                  );
                } else {
                  return Container();
                }
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
