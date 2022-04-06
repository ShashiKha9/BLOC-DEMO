import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/ui/widgets/buttons.dart';
import 'package:rescu_organization_portal/ui/widgets/text_input_decoration.dart';

import '../adaptive_items.dart';
import '../adaptive_utils.dart';
import '../adaptive_widgets.dart';
import 'custom_colors.dart';
import 'loading_container.dart';

class SearchableList extends StatelessWidget {
  final String? searchHint;
  final Widget? searchIcon;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final List<AdaptiveListItem>? list;
  final ScrollController controller = ScrollController();
  final List<AdaptiveItemAction>? actions;
  SearchableList(
      {Key? key,
      this.searchHint,
      this.searchIcon,
      this.onSearchSubmitted,
      this.list,
      this.onSearchChanged,
      this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        children: [
          TextField(
            decoration: TextInputDecoration(
              hintText: searchHint,
              suffixIcon: searchIcon,
            ),
            onSubmitted: onSearchSubmitted,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 10),
          list!.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: list?.length ?? 0,
                      controller: controller,
                      itemBuilder: (ctx, index) {
                        return AdaptiveListTile(item: list![index]);
                      }))
              : Expanded(
                  child: Container(
                    height: 50,
                    color: AppColor.baseBackground,
                    child: const Center(
                      child: Text(
                        "No records found",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
          actions != null
              ? ButtonBar(
                  children: actions!
                      .map((e) => AppButtonWithIcon(
                            icon: e.icon,
                            onPressed: e.onTap,
                            buttonText: e.label,
                          ))
                      .toList(),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}

class Grid extends StatelessWidget {
  final List<AdaptiveGridItem> list;

  const Grid({Key? key, required this.list}) : super(key: key);

  int crossAxisCount(BoxConstraints box) {
    if (isMobile(box)) return 1;
    if (isCompact(box)) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount(box)),
          itemBuilder: (ctx, index) => Card(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GestureDetector(
                            onTap: list[index].onPressed,
                            child: list[index].content))),
                ButtonBar(
                  children: list[index].actions.map((action) {
                    return TextButton.icon(
                        onPressed: action.onTap,
                        icon: action.icon,
                        label: Text(action.label));
                  }).toList(),
                )
              ])),
          itemCount: list.length);
    });
  }
}

class ModalRouteWidget extends StatefulWidget {
  final ValueGetter<State<ModalRouteWidget>> stateGenerator;

  const ModalRouteWidget({Key? key, required this.stateGenerator})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return stateGenerator();
  }
}

abstract class BaseModalRouteState extends State<ModalRouteWidget> {
  BaseModalRouteState({this.resizeToAvoidBottomInset = true});
  final bool resizeToAvoidBottomInset;
  String getTitle();

  Widget content(BuildContext context);

  List<AdaptiveItemAction> getActions();

  final LoadingController _loadingController = LoadingController();

  showLoader() {
    _loadingController.show();
  }

  hideLoader() {
    _loadingController.hide();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      return LoadingContainer(
        blockPopOnLoad: true,
        controller: _loadingController,
        child: Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: AppBar(elevation: 0, title: Text(getTitle())),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              children: [
                Expanded(child: content(context)),
                ButtonBar(
                    alignment: isMobile(box) && getActions().length > 1
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                    children: getActions()
                        .map((e) => AppButtonWithIcon(
                              icon: e.icon,
                              onPressed: e.onTap,
                              buttonText: e.label,
                            ))
                        .toList())
              ],
            ),
          ),
        ),
      );
    });
  }
}

class NavigationItemContent extends StatelessWidget {
  final dynamic title;
  final Widget content;
  final List<AdaptiveItemAction> actions;
  final LoadingController loader;
  final Widget? headerAction;
  const NavigationItemContent(
      {required this.title,
      required this.content,
      required this.actions,
      required this.loader,
      this.headerAction,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      blockPopOnLoad: true,
      controller: loader,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: title is String
                    ? Text(
                        title,
                        style: const TextStyle(fontSize: 18),
                      )
                    : title,
              ),
              headerAction ?? const SizedBox()
            ],
          ),
          const Divider(
            thickness: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: content),
          ButtonBar(
              children: actions
                  .map((e) => AppButtonWithIcon(
                        icon: e.icon,
                        onPressed: e.onTap,
                        buttonText: e.label,
                      ))
                  .toList())
        ],
      ),
    );
  }
}

Widget buildPill(String text, {Color? bgColor, TextStyle? style}) {
  return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: bgColor ?? Colors.yellow,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Text(text,
          style: style ?? const TextStyle(fontWeight: FontWeight.bold)));
}

class ChatCurrentRoute {
  static bool _isChatCurrentRoute = false;
  static String _channelId = "";
  static setChatCurrentRoute(
      {bool isChatCurrentRoute = false, String channelId = ""}) {
    _isChatCurrentRoute = isChatCurrentRoute;
    _channelId = channelId;
  }

  static bool isChatCurrentRoute() {
    return _isChatCurrentRoute;
  }

  static String getChannelId() {
    return _channelId;
  }
}
