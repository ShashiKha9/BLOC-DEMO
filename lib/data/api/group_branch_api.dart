import 'package:TEST/data/api/base_api.dart';
import 'package:TEST/data/dto/group_branch_dto.dart';
import 'package:dio/dio.dart';

abstract class IGroupBranchApi {
  Future<ApiResponse> addGroupBranch(GroupBranchDto dto);
  Future<ApiDataResponse<List<GroupBranchDto>>> getGroupBranches(
      String groupId, String filter);
  Future<ApiDataResponse<GroupBranchDto>> getGroupBranch(String id);
  Future<ApiResponse> updateGroupBranch(GroupBranchDto dto);
}

class GroupBranchApi extends BaseApi implements IGroupBranchApi {
  GroupBranchApi(Dio dio) : super(dio);

  @override
  Future<ApiResponse> addGroupBranch(GroupBranchDto dto) async {
    return await wrapCall(() async {
      await dio.post("/groupbranches", data: dto.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiDataResponse<GroupBranchDto>> getGroupBranch(String id) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groupbranches/$id");
      return OkData(GroupBranchDto.fromJson(result.data));
    });
  }

  @override
  Future<ApiDataResponse<List<GroupBranchDto>>> getGroupBranches(
      String groupId, String filter) async {
    return await wrapDataCall(() async {
      var result = await dio
          .get("/groupbranches/$groupId", queryParameters: {'filter': filter});
      return OkData((result.data as Iterable)
          .map((e) => GroupBranchDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupBranch(GroupBranchDto dto) async {
    return await wrapCall(() async {
      await dio.put("/groupbranches", data: dto.toJson());
      return Ok();
    });
  }
}
