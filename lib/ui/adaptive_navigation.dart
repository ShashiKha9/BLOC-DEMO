import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rescu_organization_portal/data/api/group_branch_api.dart';
import 'package:rescu_organization_portal/data/api/group_info_api.dart';
import 'package:rescu_organization_portal/data/blocs/logout_bloc.dart';
import 'package:rescu_organization_portal/data/dto/group_branch_dto.dart';
import 'package:rescu_organization_portal/ui/content/account/change_password.dart';
import 'package:rescu_organization_portal/ui/content/domains/domains.dart';
import 'package:rescu_organization_portal/ui/content/groupBranches/group_branches.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentHistory/group_incident_history.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypeQuestions/group_incident_type_questions.dart';
import 'package:rescu_organization_portal/ui/content/groupIncidentTypes/group_incident_types.dart';
import 'package:rescu_organization_portal/ui/content/login/login_route.dart';
import 'package:rescu_organization_portal/ui/content/users/users.dart';
import '../data/api/base_api.dart';
import '../data/dto/group_info_dto.dart';
import 'adaptive_utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'content/groupaddresses/group_addresses.dart';
import 'content/groupcontacts/group_contacts.dart';
import 'content/groupinvitecontacts/group_invite_contacts.dart';
import 'widgets/custom_colors.dart';
import 'widgets/size_config.dart';

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

mixin AppBarBranchSelectionMixin on Widget {
  void branchSelection(BuildContext context, String? branchId);
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
  List<GroupBranchDto>? _branches = [];
  ValueNotifier<String?>? _selectedBranch = ValueNotifier("");

  @override
  void initState() {
    _determineMenuItems();
    super.initState();
  }

  void _determineMenuItems() async {
    var result = await context.read<IGroupInfoApi>().getLoggedInUserGroup();
    if (result is OkData<GroupInfoDto> && result.dto.isFleetUser()) {
      var branchRes = await context
          .read<IGroupBranchApi>()
          .getGroupBranches(result.dto.id, "");
      if (branchRes is OkData<List<GroupBranchDto>>) {
        _branches = branchRes.dto;
        _selectedBranch = ValueNotifier(_branches?.first.id);
      }

      navigation = [
        ContentNavigationItem(
            "Contacts",
            const Icon(Icons.contacts),
            GroupContactsContent(
              groupId: result.dto.id,
              branchId: _selectedBranch!.value,
            )),
        ContentNavigationItem(
            "Addresses",
            const Icon(Icons.location_pin),
            GroupAddressesContent(
              groupId: result.dto.id,
              selectedBranchId: _selectedBranch!.value,
            )),
        ContentNavigationItem(
            "Invitees",
            const Icon(Icons.contacts),
            GroupInviteContactsContent(
              groupId: result.dto.id,
              branchId: _selectedBranch!.value,
            )),
        ContentNavigationItem(
            "Incident Types",
            const Icon(Icons.report),
            GroupIncidentTypesContent(
              groupId: result.dto.id,
              branchId: _selectedBranch!.value,
            )),
        ContentNavigationItem(
            "Questions",
            const Icon(Icons.question_answer),
            GroupIncidentTypeQuestionContent(
              groupId: result.dto.id,
              branchId: _selectedBranch!.value,
            )),
        ContentNavigationItem("Branches", const Icon(Icons.apartment),
            GroupBranchesContent(groupId: result.dto.id)),
        ExpansionNavigationItem("Reports", const Icon(Icons.dashboard), [
          ContentNavigationItem(
              "Incident History",
              const Icon(Icons.report),
              GroupIncidentHistoryContent(
                groupId: result.dto.id,
                branchId: _selectedBranch!.value!,
              ))
        ]),
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
        if (item is ContentNavigationItem) {
          viewNotifier!.value = item.content;
          if (item.content is AppBarBranchSelectionMixin) {
            Future.delayed(const Duration(milliseconds: 300), (() {
              (item.content as AppBarBranchSelectionMixin)
                  .branchSelection(context, _selectedBranch!.value);
            }));
          }
        }
      });
    });

    var item = navigationNotifier!.value;
    if (item is ContentNavigationItem) {
      if (item.content is AppBarBranchSelectionMixin) {
        Future.delayed(const Duration(milliseconds: 300), (() {
          (item.content as AppBarBranchSelectionMixin)
              .branchSelection(context, _selectedBranch!.value);
        }));
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    viewNotifier!.dispose();
    navigationNotifier!.dispose();
    _selectedBranch!.dispose();
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
                    return Mobile(navigation, viewNotifier!,
                        navigationNotifier!, _branches!, _selectedBranch!);
                  }
                  // For now, assuming 600
                  if (isMobile(box)) {
                    return Mobile(navigation, viewNotifier!,
                        navigationNotifier!, _branches!, _selectedBranch!);
                  }
                  if (isCompact(box)) {
                    return Compact(navigation, viewNotifier!,
                        navigationNotifier!, _branches!, _selectedBranch!);
                  }
                  return Full(navigation, viewNotifier!, navigationNotifier!,
                      _branches!, _selectedBranch!);
                },
              )
            : Container(
                color: AppColor.baseBackground,
                child: Center(
                  child: SpinKitFadingCircle(
                    color: Colors.white,
                    size: SizeConfig.size(4),
                  ),
                ),
              ));
  }
}

abstract class AdaptiveLayoutBase extends StatelessWidget {
  final List<NavigationItem> navigation;
  final ValueNotifier<Widget> primaryContentNotifier;
  final ValueNotifier<NavigationItem> selectedNavigationItemNotifier;
  final List<GroupBranchDto> branches;
  final ValueNotifier<String?> selectedBranch;

  const AdaptiveLayoutBase(this.navigation, this.primaryContentNotifier,
      this.selectedNavigationItemNotifier, this.branches, this.selectedBranch,
      {Key? key})
      : super(key: key);
}

class Mobile extends AdaptiveLayoutBase {
  const Mobile(
      List<NavigationItem> navigation,
      ValueNotifier<Widget> viewNotifier,
      ValueNotifier<NavigationItem> navigationNotifier,
      List<GroupBranchDto> branches,
      final ValueNotifier<String?> selectedBranch,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, branches,
            selectedBranch,
            key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Semantics(
      label: selectedNavigationItemNotifier.value.title,
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: content is AppBarBranchSelectionMixin ? 100 : null,
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Rescu Group Portal"),
              if (content is AppBarBranchSelectionMixin)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: DropdownButtonFormField(
                      hint: const Text("Switch Branch"),
                      isDense: true,
                      value: selectedBranch.value,
                      items: branches
                          .map((e) => DropdownMenuItem(
                                child: Text(e.name),
                                value: e.id,
                              ))
                          .toList(),
                      onChanged: (value) {
                        selectedBranch.value = value as String?;
                        content.branchSelection(context, value);
                      }),
                ),
            ]),
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
      List<GroupBranchDto> branches,
      final ValueNotifier<String?> selectedBranch,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, branches,
            selectedBranch,
            key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(children: [
            const Text("Rescu Group Portal"),
            if (content is AppBarBranchSelectionMixin)
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Tooltip(
                    message: "Switch Branch",
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: DropdownButtonFormField(
                          hint: const Text("Switch Branch"),
                          isDense: true,
                          value: selectedBranch.value,
                          items: branches
                              .map((e) => DropdownMenuItem(
                                    child: Text(e.name),
                                    value: e.id,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            selectedBranch.value = value as String?;
                            content.branchSelection(context, value);
                          }),
                    ),
                  ),
                ),
              ),
          ]),
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
      List<GroupBranchDto> branches,
      final ValueNotifier<String?> selectedBranch,
      {Key? key})
      : super(navigation, viewNotifier, navigationNotifier, branches,
            selectedBranch,
            key: key);

  @override
  Widget build(BuildContext context) {
    var content = primaryContentNotifier.value;
    return Semantics(
        label: selectedNavigationItemNotifier.value.title,
        child: Scaffold(
          appBar: AppBar(
              title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Rescu Group Portal"),
                    if (content is AppBarBranchSelectionMixin)
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Tooltip(
                            message: "Switch Branch",
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: DropdownButtonFormField(
                                  hint: const Text("Switch Branch"),
                                  isDense: true,
                                  value: selectedBranch.value,
                                  items: branches
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e.name),
                                            value: e.id,
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    selectedBranch.value = value as String?;
                                    content.branchSelection(context, value);
                                  }),
                            ),
                          ),
                        ),
                      ),
                  ]),
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
