import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_type_question_dto.dart';

abstract class IGroupIncidentTypeQuestionApi {
  Future<ApiDataResponse<List<GroupIncidentTypeQuestionDto>>> get(
      String id, String filter);
  Future<ApiResponse> add(String id, GroupIncidentTypeQuestionDto dto);
  Future<ApiResponse> update(
      String id, String questionId, GroupIncidentTypeQuestionDto dto);
  Future<ApiResponse> delete(String id, String questionId);
}

class GroupIncidentTypeQuestionApi extends BaseApi
    implements IGroupIncidentTypeQuestionApi {
  GroupIncidentTypeQuestionApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupIncidentTypeQuestionDto>>> get(
      String id, String filter) async {
    return await wrapDataCall(() async {
      var result =
          await dio.get("groups/$id/incidenttypes/questions?Filter=$filter");
      return OkData((result.data as Iterable)
          .map((e) => GroupIncidentTypeQuestionDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> add(String id, GroupIncidentTypeQuestionDto dto) async {
    return await wrapCall(() async {
      await dio.post("groups/$id/incidenttypes/questions", data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> update(
      String id, String questionId, GroupIncidentTypeQuestionDto dto) async {
    return await wrapCall(() async {
      await dio.put("groups/$id/incidenttypes/questions/$questionId",
          data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> delete(String id, String questionId) async {
    return await wrapCall(() async {
      await dio.delete("groups/$id/incidenttypes/questions/$questionId");
      return Ok();
    });
  }
}
