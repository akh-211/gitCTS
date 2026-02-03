@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: 'Company Bank'
}
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_RCOMPANY_BANK
  provider contract transactional_query
  as projection on ZRCOMPANY_BANK
  association [1..1] to ZRCOMPANY_BANK as _BaseEntity on $projection.CompanyCode = _BaseEntity.CompanyCode
{
  @EndUserText: {
    label: 'Company Code', 
    quickInfo: 'Company Code'
  }
  @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CompanyCodeStdVH',
                     element: 'CompanyCode' }
        }]
      @ObjectModel.foreignKey.association: '_BaseEntity'
  key CompanyCode,
  @EndUserText: {
    label: 'Company Name', 
    quickInfo: 'Name of Company Code or Company'
  }
  CompanyCodeName,
  _bank : redirected to composition child ZC_RCOMPANY_BANK_DETAIL,
  _BaseEntity
}
