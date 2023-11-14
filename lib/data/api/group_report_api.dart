import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_incident_history_dto.dart';

abstract class IGroupReportApi {
  Future<ApiDataResponse<List<GroupIncidentHistoryDto>>>
      getGroupIncidentHistory(String groupId, String? filter, String branchId);
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
}
