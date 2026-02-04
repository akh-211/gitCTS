@AbapCatalog.sqlViewName: 'ZHOUSEBANK_VH1'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@EndUserText.label: 'Value Help House Bank'

@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED

@ClientHandling.algorithm: #SESSION_VARIABLE

@Search.searchable: true
@ObjectModel.representativeKey: 'HouseBank'
@ObjectModel.dataCategory: #VALUE_HELP
@Consumption.ranked: true
@ObjectModel.usageType.dataClass: #MASTER
@ObjectModel.usageType.sizeCategory: #M
@ObjectModel.usageType.serviceQuality: #C

@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC

define view ZHOUSEBANK_VH as select from I_Housebank
{
      //I_Housebank
      @ObjectModel.foreignKey.association: '_CompanyCode'
      @UI.lineItem: [
     { position: 2, importance: #HIGH}
     ]
@Consumption.filter.hidden: true
  key CompanyCode,
      @Search: {defaultSearchElement: true, fuzzinessThreshold: 0.8}
      @Search.ranking: #HIGH
      @UI.lineItem: [
     { position: 1, importance: #HIGH}
     ]
  key HouseBank,
      BankCountry,
      BankInternalID,
      PhoneNumber1,
      TaxID1,
      ContactPersonName,
      Language,
      BusinessPlace,
      EDIPartner,
      EDISignatureType,
      DataMediumExchangeBank,
      DataMediumReceivingBank,
      CustomerByHouseBank,
      BankControlKey,
      DataExchangeInstructionKey,
      ExecutionLeadDays,
      CentralBankReportIsRequired,
      RegionByCentralBank,
      PaymentIsForwardedToCentralBk,
      ChargeAccountCurrencyISOCode,
      ChargeAccount,
      ChargeAccountBank,
      OrderingCompanyByBank,
      /* Associations */
      //I_Housebank
      //@Consumption.hidden:true
      //_Bank,
      _CompanyCode

}
