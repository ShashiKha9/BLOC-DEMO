import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import '../dto/group_manage_contacts_dto.dart';

abstract class IManageGroupContactsApi {
  Future<ApiDataResponse<List<GroupManageContactBranchDto>>>
      getGroupContactBranchIncidentDetails(
          String groupId, String filter, String branchId);
}

class ManageGroupContactsApi extends BaseApi
    implements IManageGroupContactsApi {
  ManageGroupContactsApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupManageContactBranchDto>>>
      getGroupContactBranchIncidentDetails(
          String groupId, String filter, String branchId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/$groupId/contacts/branch/incidents",
          queryParameters: {"Filter": filter, "BranchId": branchId});
      return OkData((result.data as Iterable)
          .map((e) => GroupManageContactBranchDto.fromJson(e))
          .toList());
    });
  }
}
