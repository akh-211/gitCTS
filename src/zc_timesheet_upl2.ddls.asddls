@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTIMESHEET_UPL2'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TIMESHEET_UPL2
  provider contract transactional_query
  as projection on ZR_TIMESHEET_UPL2
  association [1..1] to ZR_TIMESHEET_UPL2 as _BaseEntity on $projection.UplID = _BaseEntity.UplID
{
  key UplID,
  Filename,
  Status,
  Succes,
  Failed,
  @Semantics: {
    user.createdBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  LocalCreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  _BaseEntity
}
