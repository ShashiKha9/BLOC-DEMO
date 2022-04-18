import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_users_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_navigation.dart';
import 'package:rescu_organization_portal/ui/content/users/add_emails.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';

class UsersContent extends StatefulWidget with FloatingActionMixin {
  const UsersContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UsersContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(stateGenerator: () => AddUserEmailModelState());
    })).then((_) {
      //Refresh list on app bar back or cancel button from Add Promo code Screen,
      //As we don't have control over App bar back button.
      context.read<GroupUserBloc>().add(GetGroupUsers(""));
    });
  }
}

class _UsersContentState extends State<UsersContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _users = [];

  @override
  void initState() {
    context.read<GroupUserBloc>().add(GetGroupUsers(""));
    super.initState();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingContainer(
      controller: _loadingController,
      blockPopOnLoad: true,
      child: BlocListener(
        bloc: context.read<GroupUserBloc>(),
        listener: (context, state) {
          if (state is GroupUserLoadingState) {
            setState(() {
              _loadingController.show();
            });
          } else {
            setState(() {
              _loadingController.hide();
            });
            if (state is GetGroupUsersSuccessState) {
              setState(() {
                _users.clear();
                _users.addAll(state.groupUsers.map((e) {
                  List<AdaptiveContextualItem> contextualItems = [];

                  contextualItems.add(AdaptiveItemButton(
                      e.isExcluded ? "INCLUDE" : "EXCLUDE",
                      e.isExcluded
                          ? const Icon(
                              Icons.account_circle_rounded,
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.account_circle_rounded,
                              color: Colors.red,
                            ), () async {
                    showConfirmationDialog(
                        context: context,
                        body:
                            "Are you sure you want to ${e.isExcluded ? "include" : "exclude"} this account?",
                        onPressedOk: () {
                          e.isExcluded = !e.isExcluded;
                          context.read<GroupUserBloc>().add(UpdateGroupUser(e));
                        });
                  }));

                  return AdaptiveListItem(
                      e.email, "", const Icon(Icons.person), contextualItems,
                      onPressed: () {});
                }));
              });
            }
            if (state is GetGroupUsersErrorState ||
                state is UpdateGroupUserErrorState) {
              ToastDialog.error(MessagesConst.internalServerError);
            }
            if (state is GetGroupUsersNotFoundState) {
              ToastDialog.error(MessagesConst.groupUsersNotFound);
            }
            if (state is UpdateGroupUserSuccessState) {
              context.read<GroupUserBloc>().add(GetGroupUsers(_searchValue));
              ToastDialog.success(MessagesConst.groupUserUpdateSuccess);
            }
          }
        },
        child: SearchableList(
            searchHint: "Email Address",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context.read<GroupUserBloc>().add(GetGroupUsers(value));
            },
            list: _users),
      ),
    );
  }
}
