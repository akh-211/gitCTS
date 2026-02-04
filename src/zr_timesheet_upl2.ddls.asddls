@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTIMESHEET_UPL2'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TIMESHEET_UPL2
  as select from ztimesheet_upl2
{
  key upl_id as UplID,
  filename as Filename,
  status as Status,
  succes as Succes,
  failed as Failed,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
