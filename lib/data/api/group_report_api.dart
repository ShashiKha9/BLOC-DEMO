import 'package:TEST/data/api/base_api.dart';
import 'package:TEST/data/dto/group_incident_history_dto.dart';
import 'package:dio/dio.dart';

abstract class IGroupReportApi {
  Future<ApiDataResponse<List<GroupIncidentHistoryDto>>>
      getGroupIncidentHistory(String groupId, String? filter, String branchId);

  Future<ApiDataResponse<GroupIncidentHistoryDto>> get(String signalId);

  Future<ApiResponse> closeIncident(String signalId);
}

class GroupReportApi extends BaseApi implements IGroupReportApi {
  GroupReportApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupIncidentHistoryDto>>>
      getGroupIncidentHistory(
          String groupId, String? filter, String branchId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/report/incidents", queryParameters: {
        'groupId': groupId,
        'filter': filter,
        'branchId': branchId
      });

      return OkData((result.data as Iterable)
          .map((e) => GroupIncidentHistoryDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiDataResponse<GroupIncidentHistoryDto>> get(String signalId) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/report/incidents/$signalId");

      return OkData(GroupIncidentHistoryDto.fromJson(result.data));
    });
  }

  @override
  Future<ApiResponse> closeIncident(String signalId) async {
    return await wrapCall(() async {
      await dio.post("/signal/$signalId/close",
          queryParameters: {'api-version': '2.0'});
      return Ok();
    });
  }
}
