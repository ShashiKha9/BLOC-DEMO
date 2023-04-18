import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_contact_dto.dart';

import 'base_api.dart';

abstract class IGroupIncidentContactsApi {
  Future<ApiDataResponse<List<GroupIncidentContactDto>>>
      getGroupIncidentContacts(String groupId, String? filter);
  Future<ApiResponse> addGroupIncidentContact(
      String groupId, GroupIncidentContactDto contact);
  Future<ApiResponse> updateGroupIncidentContact(String groupId,
      String groupIncidentContactId, GroupIncidentContactDto contact);
  Future<ApiResponse> deleteGroupIncidentContact(
      String groupId, String groupIncidentContactId);
}

class GroupIncidentContactsApi extends BaseApi
    implements IGroupIncidentContactsApi {
  GroupIncidentContactsApi(Dio dio) : super(dio);

  @override
  Future<ApiResponse> addGroupIncidentContact(
      String groupId, GroupIncidentContactDto contact) async {
    return await wrapCall(() async {
      await dio.post("/groups/$groupId/contacts", data: contact.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> deleteGroupIncidentContact(
      String groupId, String groupIncidentContactId) async {
    return await wrapCall(() async {
      await dio.delete("/groups/$groupId/contacts/$groupIncidentContactId");
      return Ok();
    });
  }

  @override
  Future<ApiDataResponse<List<GroupIncidentContactDto>>>
      getGroupIncidentContacts(String groupId, String? filter) async {
    return await wrapDataCall(() async {
      var result = await dio
          .get("/groups/contacts", queryParameters: {'Filter': filter});
      return OkData((result.data as Iterable)
          .map((e) => GroupIncidentContactDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupIncidentContact(String groupId,
      String groupIncidentContactId, GroupIncidentContactDto contact) async {
    return await wrapCall(() async {
      await dio.put("/groups/$groupId/contacts/$groupIncidentContactId",
          data: contact.toJson());
      return Ok();
    });
  }
}
