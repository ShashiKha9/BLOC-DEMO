import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescu_organization_portal/data/blocs/group_domain_bloc.dart';
import 'package:rescu_organization_portal/data/constants/messages.dart';
import 'package:rescu_organization_portal/ui/adaptive_items.dart';
import 'package:rescu_organization_portal/ui/adaptive_navigation.dart';
import 'package:rescu_organization_portal/ui/content/domains/add_domain.dart';
import 'package:rescu_organization_portal/ui/widgets/common_widgets.dart';
import 'package:rescu_organization_portal/ui/widgets/dialogs.dart';
import 'package:rescu_organization_portal/ui/widgets/loading_container.dart';

class DomainsContent extends StatefulWidget with FloatingActionMixin {
  const DomainsContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DomainsContentState();

  @override
  Widget fabIcon(BuildContext context) {
    return const Icon(Icons.add);
  }

  @override
  void onFabPressed(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return ModalRouteWidget(stateGenerator: () => AddDomainModelState());
    })).then((_) {
      //Refresh list on app bar back or cancel button from Add Promo code Screen,
      //As we don't have control over App bar back button.
      context.read<GroupDomainBloc>().add(GetGroupDomains(""));
    });
  }
}

class _DomainsContentState extends State<DomainsContent> {
  final LoadingController _loadingController = LoadingController();
  String _searchValue = "";
  final List<AdaptiveListItem> _domains = [];

  @override
  void initState() {
    context.read<GroupDomainBloc>().add(GetGroupDomains(""));
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
        bloc: context.read<GroupDomainBloc>(),
        listener: (context, state) {
          if (state is GroupDomainLoadingState) {
            setState(() {
              _loadingController.show();
            });
          } else {
            setState(() {
              _loadingController.hide();
            });
            if (state is GetGroupDomainsSuccessState) {
              setState(() {
                _domains.clear();
                _domains.addAll(state.groupDomains.map((e) {
                  List<AdaptiveContextualItem> contextualItems = [];

                  return AdaptiveListItem(
                      e.domain, "", const Icon(Icons.web), contextualItems,
                      onPressed: () {});
                }));
              });
            }
            if (state is GetGroupDomainsErrorState ||
                state is UpdateGroupDomainErrorState) {
              ToastDialog.error(MessagesConst.internalServerError);
            }
            if (state is GetGroupDomainsNotFoundState) {
              ToastDialog.error(MessagesConst.groupDomainsNotFound);
            }
            if (state is UpdateGroupDomainSuccessState) {
              context
                  .read<GroupDomainBloc>()
                  .add(GetGroupDomains(_searchValue));
              ToastDialog.success(MessagesConst.groupDomainUpdateSuccess);
            }
          }
        },
        child: SearchableList(
            searchHint: "Domain",
            searchIcon: const Icon(Icons.search),
            onSearchSubmitted: (value) {
              _searchValue = value;
              context.read<GroupDomainBloc>().add(GetGroupDomains(value));
            },
            list: _domains),
      ),
    );
  }
}
