import 'package:rescu_organization_portal/data/dto/group_domain_dto.dart';

class GroupDomainModel {
  late String id;
  late String domain;
  late String groupId;

  GroupDomainModel(
      {required this.id, required this.domain, required this.groupId});

  GroupDomainModel.fromDto(GroupDomainDto dto) {
    id = dto.id;
    domain = dto.domain;
    groupId = dto.groupId;
  }

  GroupDomainDto toDto() {
    return GroupDomainDto(id: id, domain: domain, groupId: groupId);
  }
}
