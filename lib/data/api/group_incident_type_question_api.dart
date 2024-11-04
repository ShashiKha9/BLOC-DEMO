import 'package:TEST/data/api/base_api.dart';
import 'package:TEST/data/dto/group_incident_type_question_dto.dart';
import 'package:dio/dio.dart';

abstract class IGroupIncidentTypeQuestionApi {
  Future<ApiDataResponse<List<GroupIncidentTypeQuestionDto>>> get(
      String id, String filter, String? branchId, String? incidentTypeId);
  Future<ApiResponse> add(String id, GroupIncidentTypeQuestionDto dto);
  Future<ApiResponse> update(
      String id, String questionId, GroupIncidentTypeQuestionDto dto);
  Future<ApiDataResponse<GroupIncidentTypeQuestionDto>> getOne(String id);
  Future<ApiResponse> delete(String id, String questionId);
  Future<ApiResponse> copy(String id, String branchId, String incidentTypeId,
      List<String> questions);
  Future<ApiResponse> changeQuestionOrder(
      String incidentTypeId, String questionId, String order);
}

class GroupIncidentTypeQuestionApi extends BaseApi
    implements IGroupIncidentTypeQuestionApi {
  GroupIncidentTypeQuestionApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupIncidentTypeQuestionDto>>> get(String id,
      String filter, String? branchId, String? incidentTypeId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("groups/$id/incidenttypes/questions",
          queryParameters: {
            "Filter": filter,
            "BranchId": branchId,
            "incidentTypeId": incidentTypeId
          });
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

  @override
  Future<ApiDataResponse<GroupIncidentTypeQuestionDto>> getOne(
      String id) async {
    return await wrapDataCall(() async {
      var result = await dio.get("groups/incidenttypes/questions/$id");
      return OkData(GroupIncidentTypeQuestionDto.fromJson(result.data));
    });
  }

  @override
  Future<ApiResponse> copy(String id, String branchId, String incidentTypeId,
      List<String> questions) async {
    return await wrapCall(() async {
      await dio.post("groups/$id/questions/copy", data: {
        "BranchId": branchId,
        "IncidentTypeId": incidentTypeId,
        "Questions": questions
      });
      return Ok();
    });
  }

  @override
  Future<ApiResponse> changeQuestionOrder(
      String incidentTypeId, String questionId, String order) async {
    return await wrapCall(() async {
      await dio.put(
          "groups/incidenttypes/$incidentTypeId/questions/$questionId/reorder/$order");
      return Ok();
    });
  }
}
