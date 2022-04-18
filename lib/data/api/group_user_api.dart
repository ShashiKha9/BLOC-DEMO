import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_user_dto.dart';

abstract class IGroupUserApi {
  Future<ApiDataResponse<List<GroupUserDto>>> addGroupUser(List<String> emails);
  Future<ApiDataResponse<List<GroupUserDto>>> getGroupUsers(String filter);
  Future<ApiDataResponse<GroupUserDto>> getGroupUser(String id);
  Future<ApiResponse> updateGroupUser(GroupUserDto dto, String userId);
}

class GroupUserApi extends BaseApi implements IGroupUserApi {
  GroupUserApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<List<GroupUserDto>>> addGroupUser(
      List<String> emails) async {
    return await wrapDataCall(() async {
      var result = await dio.post("/groups/users", data: {'Emails': emails});
      return OkData((result.data as Iterable)
          .map((e) => GroupUserDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiDataResponse<GroupUserDto>> getGroupUser(String id) async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/users/$id");
      return OkData(GroupUserDto.fromJson(result.data));
    });
  }

  @override
  Future<ApiDataResponse<List<GroupUserDto>>> getGroupUsers(
      String filter) async {
    return await wrapDataCall(() async {
      var result =
          await dio.get("/groups/users", queryParameters: {'Filter': filter});
      return OkData((result.data as Iterable)
          .map((e) => GroupUserDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupUser(GroupUserDto dto, String userId) async {
    return await wrapCall(() async {
      await dio.patch("/groups/users/$userId",
          queryParameters: null, data: dto.toJson());
      return Ok();
    });
  }
}
