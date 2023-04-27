import 'package:dio/dio.dart';
import 'package:rescu_organization_portal/data/api/base_api.dart';
import 'package:rescu_organization_portal/data/dto/group_info_dto.dart';

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
