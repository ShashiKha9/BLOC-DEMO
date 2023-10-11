import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_dto.dart';

abstract class IGroupIncidentTypeApi {
  Future<ApiDataResponse<List<GroupIncidentTypeDto>>> get(
      String filter, String? branchId);
  Future<ApiResponse> add(String id, GroupIncidentTypeDto dto);
  Future<ApiResponse> update(
      String id, String incidentId, GroupIncidentTypeDto dto);
  Future<ApiResponse> delete(String id, String incidentId);
}

class GroupIncidentTypeApi extends BaseApi implements IGroupIncidentTypeApi {
  GroupIncidentTypeApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupIncidentTypeDto>>> get(
      String filter, String? branchId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("groups/incidenttypes",
          queryParameters: {"Filter": filter, "BranchId": branchId});
      return OkData((result.data as Iterable)
          .map((e) => GroupIncidentTypeDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> add(String id, GroupIncidentTypeDto dto) async {
    return await wrapCall(() async {
      await dio.post("groups/$id/incidenttypes", data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> update(
      String id, String incidentId, GroupIncidentTypeDto dto) async {
    return await wrapCall(() async {
      await dio.put("groups/$id/incidenttypes/$incidentId", data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> delete(String id, String incidentId) async {
    return await wrapCall(() async {
      await dio.delete("groups/$id/incidenttypes/$incidentId");
      return Ok();
    });
  }
}