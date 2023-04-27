import 'package:dio/dio.dart';

import '../dto/group_address_dto.dart';
import 'base_api.dart';

abstract class IGroupAddressApi {
  Future<ApiDataResponse<List<GroupAddressDto>>> getGroupIncidentAddresses(
      String groupId, String? filter);
  Future<ApiResponse> addGroupIncidentAddress(
      String groupId, GroupAddressDto address);
  Future<ApiResponse> updateGroupIncidentAddress(
      String groupId, String addressId, GroupAddressDto address);
  Future<ApiResponse> deleteGroupIncidentAddress(
      String groupId, String addressId);
}

class GroupAddressApi extends BaseApi implements IGroupAddressApi {
  GroupAddressApi(Dio dio) : super(dio);

  @override
  Future<ApiResponse> addGroupIncidentAddress(
      String groupId, GroupAddressDto address) async {
    return await wrapCall(() async {
      await dio.post("/groups/$groupId/addresses", data: address.toJson());
      return Ok();
    });
  }

  @override
  Future<ApiResponse> deleteGroupIncidentAddress(
      String groupId, String addressId) async {
    return await wrapCall(() async {
      await dio.delete("/groups/$groupId/addresses/$addressId");
      return Ok();
    });
  }

  @override
  Future<ApiDataResponse<List<GroupAddressDto>>> getGroupIncidentAddresses(
      String groupId, String? filter) async {
    return await wrapDataCall(() async {
      var result = await dio
          .get("/groups/addresses", queryParameters: {'Filter': filter});
      return OkData((result.data as Iterable)
          .map((e) => GroupAddressDto.fromJson(e))
          .toList());
    });
  }

  @override
  Future<ApiResponse> updateGroupIncidentAddress(
      String groupId, String addressId, GroupAddressDto address) async {
    return await wrapCall(() async {
      await dio.put("/groups/$groupId/addresses/$addressId",
          data: address.toJson());
      return Ok();
    });
  }
}
