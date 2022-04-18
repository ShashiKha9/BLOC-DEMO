import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_domain_dto.dart';

abstract class IGroupDomainApi {
  Future<ApiResponse> addGroupDomain(GroupDomainDto dto);
  Future<ApiDataResponse<List<GroupDomainDto>>> getGroupDomains(String filter);
  Future<ApiDataResponse<GroupDomainDto>> getGroupDomain(String id);
  Future<ApiResponse> updateGroupDomain(GroupDomainDto dto, String userId);
}

class GroupDomainApi extends BaseApi implements IGroupDomainApi {
  GroupDomainApi(Dio dio) : super(dio);

  @override
  Future<ApiResponse> addGroupDomain(GroupDomainDto dto) async {
    return await wrapCall(() async {
      await dio.post("/groups/domains", data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiDataResponse<GroupDomainDto>> getGroupDomain(String id) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/domains/$id");
      return OkData(GroupDomainDto.fromJson(result.data));
    });
  }

  @override
  Future<ApiDataResponse<List<GroupDomainDto>>> getGroupDomains(
      String filter) async {
    return await wrapDataCall(() async {
      var result =
          await dio.get("/groups/domains", queryParameters: {'Filter': filter});
      return OkData((result.data as Iterable)
          .map((e) => GroupDomainDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupDomain(
      GroupDomainDto dto, String userId) async {
    return await wrapCall(() async {
      await dio.patch("/groups/domains/$userId", data: dto.toJson());
      return Ok();
    });
  }
}
