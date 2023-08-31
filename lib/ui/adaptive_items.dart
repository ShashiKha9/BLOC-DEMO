import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AdaptiveGridItem {
  final int preferredVirtualWidth;
  final Widget content;
  final List<AdaptiveItemAction> actions;
  final Function()? onPressed;

  AdaptiveGridItem(this.preferredVirtualWidth, this.content, this.actions,
      {this.onPressed});
}

class AdaptiveListItem {
  final String title;
  final String? subtitle;
  final Widget icon;
  final List<AdaptiveContextualItem> contextualItems;
  final ShapeBorder? borderDecoration;
  final Function()? onPressed;

  AdaptiveListItem(this.title, this.subtitle, this.icon, this.contextualItems,
      {this.onPressed, this.borderDecoration});
}

abstract class AdaptiveContextualItem {
  final String label;
  final int order;

  AdaptiveContextualItem(this.label, this.order);

  int compareTo(AdaptiveContextualItem b) {
    return order.compareTo(b.order);
  }
}

enum ActionCategory { primary, none }

class AdaptiveItemAction extends AdaptiveContextualItem {
  final Widget icon;
  final AsyncCallback onTap;
  final ActionCategory category;

  AdaptiveItemAction(String label, this.icon, this.onTap,
      {int order = 0, this.category = ActionCategory.none})
      : super(label, order);
}

class AdaptiveItemToggle extends AdaptiveContextualItem {
  final ValueNotifier<bool> switchNotifier;

  AdaptiveItemToggle(String label, this.switchNotifier, {int order = 0})
      : super(label, order);
}

class AdaptiveItemButton extends AdaptiveContextualItem {
  final Widget icon;
  final AsyncCallback onPressed;

  AdaptiveItemButton(String label, this.icon, this.onPressed, {int order = 0})
      : super(label, order);
}
