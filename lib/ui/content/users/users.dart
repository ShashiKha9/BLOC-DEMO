import 'package:flutter/material.dart';
import 'package:rescu_organization_portal/data/models/user_model.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/content/users/add_emails.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  var _users = <UserModel>[
    UserModel(id: "1", email: "test@example.com", isActive: true),
    UserModel(id: "2", email: "test1@example.com", isActive: true),
    UserModel(id: "3", email: "test2@example.com", isActive: true),
    UserModel(id: "4", email: "test3@example.com", isActive: false),
    UserModel(id: "5", email: "test4@example.com", isActive: true),
  ];
  var _filteredUsers = <UserModel>[];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: NavigationItemContent(
          title: "Manage Users",
          content: _buildContent(),
          actions: _buildActions(),
          loader: _loadingController),
    );
  }

  _buildContent() {
    return SearchableList(
        searchHint: "Search by Email Address",
        searchIcon: const Icon(Icons.search),
        onSearchSubmitted: (value) {
          _searchValue = value;
          _filterUsers();
        },
        list: _getUsers());
  }

  List<AdaptiveListItem> _getUsers() {
    _filterUsers();
    return _filteredUsers.map((e) {
      List<AdaptiveContextualItem> contextualItems = [];
      contextualItems.add(AdaptiveItemButton(
          e.isActive ?? true ? "DISABLE" : "ENABLE",
          e.isActive ?? true
              ? const Icon(
                  Icons.account_circle_rounded,
                  color: Colors.red,
                )
              : const Icon(
                  Icons.account_circle_rounded,
                  color: Colors.green,
                ), () async {
        showConfirmationDialog(
            context: context,
            body:
                "Are you sure you want to ${e.isActive ?? true ? "disable" : "enable"} this account?",
            onPressedOk: () {
              e.isActive = !(e.isActive ?? true);
              // context.read<CustomerBloc>().add(UpdateCustomer(e));
            });
      }));

      return AdaptiveListItem(
          e.email, "", const Icon(Icons.person), contextualItems,
          onPressed: () {});
    }).toList();
  }

  _filterUsers() {
    setState(() {
      _filteredUsers = _users;
      if (_searchValue.isNotEmpty) {
        _filteredUsers = _users
            .where((element) => element.email.contains(_searchValue))
            .toList();
      }
    });
  }

  List<AdaptiveItemAction> _buildActions() {
    return [
      AdaptiveItemAction("Add", const Icon(Icons.add), () async {
        await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return ModalRouteWidget(
              stateGenerator: () => AddUserEmailModelState());
        })).then((value) {
          if (value != null && value is List<String>) {
            setState(() {
              var users = value
                  .map((e) => UserModel(id: "145", email: e, isActive: true));
              _users = [..._users, ...users];
            });
          }
        });
      })
    ];
  }
}
