@EndUserText.label: 'Master Template'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_MasterTemplate
  as select from ztmst_template
  association to parent ZI_MasterTemplate_S as _MasterTemplateAll on $projection.SingletonID = _MasterTemplateAll.SingletonID
{
  key objectid as Objectid,
  @Semantics.largeObject : { mimeType: 'Mietype', 
                             fileName: 'Filename', 
                             contentDispositionPreference: #INLINE }  
  attachment as Attachment,
  filename as Filename,
  @Semantics.mimeType: true 
  mietype as Mietype,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  @Consumption.hidden: true
  local_last_changed_at as LocalLastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _MasterTemplateAll
}
