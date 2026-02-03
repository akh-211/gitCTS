@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'CDS Company Bank'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZRCOMPANY_BANK as select from I_CompanyCode
composition [0..*] of ZRCOMPANY_BANK_detail as _bank 
{   
    key CompanyCode as CompanyCode,
        CompanyCodeName as CompanyCodeName,
    _bank
}
