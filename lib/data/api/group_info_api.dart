import 'package:TEST/data/api/base_api.dart';
import 'package:TEST/data/dto/group_info_dto.dart';
import 'package:dio/dio.dart';

abstract class IGroupInfoApi {
  Future<ApiDataResponse<GroupInfoDto>> getLoggedInUserGroup();
}

class GroupInfoApi extends BaseApi implements IGroupInfoApi {
  GroupInfoApi(Dio dio) : super(dio);

  @override
  Future<ApiDataResponse<GroupInfoDto>> getLoggedInUserGroup() async {
    return await wrapDataCall(() async {
      var result = await dio.get("/groups/user");
      return OkData(GroupInfoDto.fromJson(result.data));
    });
  }
  
}
