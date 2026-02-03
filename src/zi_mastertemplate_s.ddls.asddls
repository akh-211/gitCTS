@EndUserText.label: 'Master Template Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MasterTemplateAll'
  }
}
define root view entity ZI_MasterTemplate_S
  as select from I_Language
    left outer join ZTMST_TEMPLATE on 0 = 0
  composition [0..*] of ZI_MasterTemplate as _MasterTemplate
{
  @UI.facet: [ {
    id: 'ZI_MasterTemplate', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Master Template', 
    position: 1 , 
    targetElement: '_MasterTemplate'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MasterTemplate,
  @UI.hidden: true
  max( ZTMST_TEMPLATE.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
