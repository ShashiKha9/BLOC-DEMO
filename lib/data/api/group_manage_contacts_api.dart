import 'package:TEST/data/api/base_api.dart';
import 'package:dio/dio.dart';
import '../dto/group_manage_contacts_dto.dart';

abstract class IManageGroupContactsApi {
  Future<ApiDataResponse<List<GroupManageContactBranchDto>>>
      getGroupContactBranchIncidentDetails(
          String groupId, String filter, String branchId);

  Future<ApiDataResponse<List<GroupManageContactBranchDto>>>
      getGroupAdminBranchIncidentDetails(
          String groupId, String filter, String branchId);

  Future<ApiResponse> updateGroupContactOrAdminBranchIncidentDetails(String groupId,
      String contactID, GroupManageContactBranchDto branchDetails);
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

  @override
  Future<ApiDataResponse<List<GroupManageContactBranchDto>>>
      getGroupAdminBranchIncidentDetails(
          String groupId, String filter, String branchId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/$groupId/admins/branch/incidents",
          queryParameters: {"Filter": filter, "BranchId": branchId});
      return OkData((result.data as Iterable)
          .map((e) => GroupManageContactBranchDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupContactOrAdminBranchIncidentDetails(String groupId,
      String contactID, GroupManageContactBranchDto branchDetails) async {
    return await wrapCall(() async {
      await dio.put("/groups/$groupId/users/$contactID/branch/incidents",
          data: branchDetails.toJson());
      return Ok();
    });
  }
}
