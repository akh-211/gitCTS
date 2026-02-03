@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Company Bank Detail'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZRCOMPANY_BANK_detail
  as select from zcompany_bank
  association to parent ZRCOMPANY_BANK as _company on $projection.Bukrs = _company.CompanyCode
{
  key itemid                as itemid,
  key bukrs                 as Bukrs,
      hbkid                 as Hbkid,
      begda                 as Begda,
      endda                 as Endda,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _company
}
