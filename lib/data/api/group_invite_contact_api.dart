import 'package:dio/dio.dart';

import '../dto/group_invite_contact_dto.dart';
import 'base_api.dart';

abstract class IGroupInviteContactsApi {
  Future<ApiDataResponse<List<GroupInviteContactDto>>> getGroupInviteContacts(
      String groupId, String? filter, String role, String? branchId);
  Future<ApiResponse> addGroupInviteContact(
      String groupId, GroupInviteContactDto contact);
  Future<ApiResponse> updateGroupInviteContact(
      String groupId, String inviteId, GroupInviteContactDto contact);
  Future<ApiResponse> deleteGroupInviteContact(String groupId, String inviteId);
}

class GroupInviteContactsApi extends BaseApi
    implements IGroupInviteContactsApi {
  GroupInviteContactsApi(Dio dio) : super(dio);

  @override
  Future<ApiResponse> addGroupInviteContact(
      String groupId, GroupInviteContactDto contact) async {
    return await wrapCall(() async {
      await dio.post("/groups/$groupId/invites", data: contact.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> deleteGroupInviteContact(
      String groupId, String inviteId) async {
    return await wrapCall(() async {
      await dio.delete("/groups/$groupId/invites/$inviteId");
      return Ok();
    });
  }

  @override
  Future<ApiDataResponse<List<GroupInviteContactDto>>> getGroupInviteContacts(
      String groupId, String? filter, String role, String? branchId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/invites", queryParameters: {
        'Filter': filter,
        'Role': role,
        'branchId': branchId
      });
      return OkData((result.data as Iterable)
          .map((e) => GroupInviteContactDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupInviteContact(
      String groupId, String inviteId, GroupInviteContactDto contact) async {
    return await wrapCall(() async {
      await dio.put("/groups/$groupId/invites/$inviteId",
          data: contact.toJson());
      return Ok();
    });
  }
}
