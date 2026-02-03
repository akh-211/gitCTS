@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Company Bank Detail'
}
@AccessControl.authorizationCheck: #CHECK
define view entity ZC_RCOMPANY_BANK_DETAIL
  as projection on ZRCOMPANY_BANK_detail
  association [1..1] to ZRCOMPANY_BANK_detail as _BaseEntity on  $projection.itemid = _BaseEntity.itemid
                                                             and $projection.Bukrs  = _BaseEntity.Bukrs
{
  key  itemid,
       @EndUserText: {
         label: 'Company Code',
         quickInfo: 'Company Code'
       }
  key  Bukrs,
       @EndUserText: {
         label: 'House Bank',
         quickInfo: 'Short Key for a House Bank'
       }
       @Consumption.valueHelpDefinition: [{
       entity: { name: 'ZHOUSEBANK_VH',  element: 'HouseBank' },
       additionalBinding: [{
       localElement: '_company.CompanyCode',    
       element: 'CompanyCode',
       usage: #FILTER
       }],
       useForValidation: true
       }]
       Hbkid,
       @EndUserText: {
         label: 'Start Date',
         quickInfo: 'Start Date'
       }
       Begda,
       @EndUserText: {
         label: 'End Date',
         quickInfo: 'End Date'
       }
       Endda,
       @EndUserText: {
         label: 'Created By',
         quickInfo: 'Created By User'
       }
       LocalCreatedBy,
       @EndUserText: {
         label: 'Created On',
         quickInfo: 'Creation Date Time'
       }
       LocalCreatedAt,
       @EndUserText: {
         label: 'Changed By',
         quickInfo: 'Local Instance Last Changed By User'
       }
       LocalLastChangedBy,
       @EndUserText: {
         label: 'Changed On',
         quickInfo: 'Local Instance Last Change Date Time'
       }
       LocalLastChangedAt,
       @EndUserText: {
         label: 'Changed On',
         quickInfo: 'Last Change Date Time'
       }
       LastChangedAt,
       _company : redirected to parent ZC_RCOMPANY_BANK,
       _BaseEntity
}
