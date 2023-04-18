import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/data/api/group_info_api.dart';
import 'package:rescu_organization_portal/data/blocs/logout_bloc.dart';
import 'package:rescu_organization_portal/ui/content/account/change_password.dart';
import 'package:rescu_organization_portal/ui/content/domains/domains.dart';
import 'package:rescu_organization_portal/ui/content/login/login_route.dart';
import 'package:rescu_organization_portal/ui/content/users/users.dart';
import '../data/api/base_api.dart';
import '../data/dto/group_info_dto.dart';
import 'adaptive_utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'content/groupcontacts/group_contacts.dart';

/*
This is a collection of responsive widgets which adapt to the user's
screen depending on the form factor of the user's device.
 */
abstract class NavigationItem {
  final String title;
  final Widget icon;

  NavigationItem(this.title, this.icon);
}

class ActionNavigationItem extends NavigationItem {
  final Function(BuildContext context) function;
  ActionNavigationItem(String title, Widget icon, this.function)
      : super(title, icon);
}

class ContentNavigationItem extends NavigationItem {
  final Widget content;
  ContentNavigationItem(String title, Widget icon, this.content)
      : super(title, icon);
}

class ExpansionNavigationItem extends NavigationItem {
  final List<NavigationItem> items;

  ExpansionNavigationItem(String title, Widget icon, this.items)
      : super(title, icon);
}

mixin FloatingActionMixin on Widget {
  Widget fabIcon(BuildContext context);
  void onFabPressed(BuildContext context);
}

mixin AppBarActionsMixin on Widget {
  List<Widget> getActions();
}

class AdaptiveNavigationLayout extends StatefulWidget {
  const AdaptiveNavigationLayout({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdaptiveNavigationLayoutState();
  }
}

class AdaptiveNavigationLayoutState extends State<AdaptiveNavigationLayout> {
  List<NavigationItem> navigation = [];

  ValueNotifier<Widget>? viewNotifier;
  ValueNotifier<NavigationItem>? navigationNotifier;

  bool _screenLoaded = false;

  @override
  void initState() {
    _determineMenuItems();
    super.initState();
  }

  void _determineMenuItems() async {
    var result = await context.read<IGroupInfoApi>().getLoggedInUserGroup();
    if (result is OkData<GroupInfoDto> && result.dto.isFleetUser()) {
      navigation = [
        ContentNavigationItem(
            "Users", const Icon(Icons.people), const UsersContent()),
        ContentNavigationItem(
            "Domains", const Icon(Icons.domain), const DomainsContent()),
        ContentNavigationItem(
            "Incident Contacts",
            const Icon(Icons.contacts),
            GroupContactsContent(
              groupId: result.dto.id,
            )),
        ContentNavigationItem(
            "Incident Addresses",
            const Icon(Icons.location_history_sharp),
            GroupContactsContent(
              groupId: result.dto.id,
            )),
        ContentNavigationItem("Change Password", const Icon(Icons.lock_clock),
            const ChangePasswordContent()),
        ActionNavigationItem("Logout", const Icon(Icons.logout), (context) {
          context.read<LogoutBloc>().add(Logout());
        }),
      ];
    } else {
      navigation = [
        ContentNavigationItem(
            "Users", const Icon(Icons.people), const UsersContent()),
        ContentNavigationItem(
            "Domains", const Icon(Icons.domain), const DomainsContent()),
        ContentNavigationItem("Change Password", const Icon(Icons.lock_clock),
            const ChangePasswordContent()),
        ActionNavigationItem("Logout", const Icon(Icons.logout), (context) {
          context.read<LogoutBloc>().add(Logout());
        }),
      ];
    }

    _screenLoaded = true;

    viewNotifier = ValueNotifier(
        navigation.whereType<ContentNavigationItem>().first.content);
    navigationNotifier = ValueNotifier(navigation.first);

    navigationNotifier!.addListener(() {
      setState(() {
        var item = navigationNotifier!.value;
        if (item is ContentNavigationItem) viewNotifier!.value = item.content;
      });
    });

    setState(() {});
  }

  @override
  void dispose() {
    viewNotifier!.dispose();
    navigationNotifier!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
        bloc: context.read<LogoutBloc>(),
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginRoute()));
          }
        },
        child: _screenLoaded
            ? LayoutBuilder(
                builder: (context, box) {
                  if (!kIsWeb) {
                    return Mobile(
                        navigation, viewNotifier!, navigationNotifier!);
                  }
                  // For now, assuming 600
                  if (isMobile(box)) {
                    return Mobile(
                        navigation, viewNotifier!, navigationNotifier!);
                  }
                  if (isCompact(box)) {
                    return Compact(
                        navigation, viewNotifier!, navigationNotifier!);
                  }
                  return Full(navigation, viewNotifier!, navigationNotifier!);
                },
              )
            : const SizedBox());
  }
}

abstract class AdaptiveLayoutBase extends StatelessWidget {
  final List<NavigationItem> navigation;
  final ValueNotifier<Widget> primaryContentNotifier;
  final ValueNotifier<NavigationItem> selectedNavigationItemNotifier;

  const AdaptiveLayoutBase(this.navigation, this.primaryContentNotifier,
      this.selectedNavigationItemNotifier,
      {Key? key})
      : super(key: key);
}

class Mobile extends AdaptiveLayoutBase {
  const Mobile(
      List<NavigationItem> navigation,
      ValueNotifier<Widget> viewNotifier,
      ValueNotifier<NavigationItem> navigationNotifier,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Semantics(
      label: selectedNavigationItemNotifier.value.title,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Rescu Group Portal"),
            actions: content is AppBarActionsMixin ? content.getActions() : []),
        drawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ...navigation
                        .map((n) => n is! ExpansionNavigationItem
                            ? _buildNavigationItem(n, context)
                            : ExpansionTile(
                                leading: n.icon,
                                title: Text(n.title),
                                children: n.items
                                    .map(
                                        (e) => _buildNavigationItem(e, context))
                                    .toList(),
                              ))
                        .toList()
                  ],
                ),
              )
            ],
          ),
        ),
        body: Semantics(label: "", child: content),
        floatingActionButton: Builder(builder: (BuildContext context) {
          if (content is FloatingActionMixin) {
            return FloatingActionButton(
                child: content.fabIcon(context),
                onPressed: () => content.onFabPressed(context));
          }
          return const SizedBox();
        }),
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem n, BuildContext context) {
    return ListTile(
        dense: true,
        leading: n.icon,
        title: Text(
          n.title,
          style: const TextStyle(fontSize: 14),
        ),
        onTap: () {
          if (n is ActionNavigationItem) {
            n.function(context);
          } else {
            selectedNavigationItemNotifier.value = n;
            Navigator.of(context).pop();
          }
        },
        selected: n == selectedNavigationItemNotifier.value);
  }
}

class Compact extends AdaptiveLayoutBase {
  const Compact(
      List<NavigationItem> navigation,
      ValueNotifier<Widget> viewNotifier,
      ValueNotifier<NavigationItem> navigationNotifier,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Scaffold(
      appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [Text("Rescu Group Portal")]),
          actions: content is AppBarActionsMixin ? content.getActions() : []),
      floatingActionButton: Builder(builder: (BuildContext context) {
        if (content is FloatingActionMixin) {
          return FloatingActionButton(
              child: content.fabIcon(context),
              onPressed: () => content.onFabPressed(context));
        }
        return const SizedBox();
      }),
      body: Row(
        children: [
          Container(
              color: Theme.of(context).cardColor,
              constraints: const BoxConstraints(maxWidth: 100),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(children: [
                      ...navigation
                          .map((n) => n is! ExpansionNavigationItem
                              ? _buildNavigationItem(n, context)
                              : PopupMenuButton(
                                  offset: const Offset(100, 0),
                                  tooltip: n.title,
                                  icon: n.icon,
                                  itemBuilder: (context) => n.items
                                      .map((e) => PopupMenuItem(
                                            child: _buildNavigationItem(
                                                e, context,
                                                subMenuItem: true),
                                          ))
                                      .toList(),
                                ))
                          .toList(),
                    ]),
                  )
                ],
              )),
          Expanded(child: content)
        ],
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem n, BuildContext context,
      {bool subMenuItem = false}) {
    return Tooltip(
      message: n.title,
      child: ListTile(
          title: n.icon,
          onTap: () {
            if (subMenuItem) Navigator.of(context).pop();
            if (n is ActionNavigationItem) {
              n.function(context);
            } else {
              selectedNavigationItemNotifier.value = n;
            }
          },
          selected: n == selectedNavigationItemNotifier.value),
    );
  }
}

class Full extends AdaptiveLayoutBase {
  const Full(
      List<NavigationItem> navigation,
      ValueNotifier<Widget> viewNotifier,
      ValueNotifier<NavigationItem> navigationNotifier,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Semantics(
        label: selectedNavigationItemNotifier.value.title,
        child: Scaffold(
          appBar: AppBar(
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [Text("Rescu Group Portal")]),
              actions:
                  content is AppBarActionsMixin ? content.getActions() : []),
          floatingActionButton: Builder(builder: (BuildContext context) {
            if (content is FloatingActionMixin) {
              return FloatingActionButton(
                  child: content.fabIcon(context),
                  onPressed: () => content.onFabPressed(context));
            }
            return const SizedBox();
          }),
          body: Row(
            children: [
              Container(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  constraints: const BoxConstraints(maxWidth: 275),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            ...navigation
                                .map((n) => n is! ExpansionNavigationItem
                                    ? _buildNavigationItem(n, context)
                                    : ExpansionTile(
                                        leading: n.icon,
                                        title: Text(n.title),
                                        children: n.items
                                            .map((e) => _buildNavigationItem(
                                                e, context))
                                            .toList(),
                                      ))
                                .toList()
                          ],
                        ),
                      )
                    ],
                  )),
              Expanded(child: content)
            ],
          ),
        ));
  }

  Widget _buildNavigationItem(NavigationItem n, BuildContext context) {
    return ListTile(
        leading: n.icon,
        title: Text(n.title),
        onTap: () {
          if (n is ActionNavigationItem) {
            n.function(context);
          } else {
            selectedNavigationItemNotifier.value = n;
          }
        },
        selected: n == selectedNavigationItemNotifier.value);
  }
}
