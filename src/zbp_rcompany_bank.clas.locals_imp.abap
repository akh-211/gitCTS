CLASS lhc_zrcompany_bank_detail DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validatedaterange FOR VALIDATE ON SAVE
      IMPORTING keys FOR zrcompany_bank_detail~validatedaterange.

    METHODS validatenooverlap FOR VALIDATE ON SAVE
      IMPORTING keys FOR zrcompany_bank_detail~validatenooverlap.
    METHODS check_housebank_company FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zrcompany_bank_detail~check_housebank_company.

ENDCLASS.

CLASS lhc_zrcompany_bank_detail IMPLEMENTATION.

  METHOD validatedaterange.
    READ ENTITIES OF zrcompany_bank IN LOCAL MODE
       ENTITY zrcompany_bank_detail
         FIELDS ( begda endda )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_details).

    LOOP AT lt_details ASSIGNING FIELD-SYMBOL(<detail>).
      IF <detail>-begda IS INITIAL.
        APPEND VALUE #(
              %key = <detail>-%key
              %msg = new_message(
                id = 'ZMSG'
                number = '000'
                severity = if_abap_behv_message=>severity-error
                v1 = 'Please Input Correct Validity Date'
              )
              %element-begda = if_abap_behv=>mk-on
              %element-endda = if_abap_behv=>mk-on
            ) TO reported-zrcompany_bank_detail.

        APPEND VALUE #(
          itemid = <detail>-itemid
          bukrs = <detail>-bukrs
        ) TO failed-zrcompany_bank_detail.
        CONTINUE.
      ENDIF.

      IF <detail>-endda IS INITIAL.
        APPEND VALUE #(
              %key = <detail>-%key
              %msg = new_message(
                id = 'ZMSG'
                number = '000'
                severity = if_abap_behv_message=>severity-error
                v1 = 'Please Input Correct Validity Date'
              )
              %element-begda = if_abap_behv=>mk-on
              %element-endda = if_abap_behv=>mk-on
            ) TO reported-zrcompany_bank_detail.

        APPEND VALUE #(
          itemid = <detail>-itemid
          bukrs = <detail>-bukrs
        ) TO failed-zrcompany_bank_detail.
        CONTINUE.
      ENDIF.

      IF <detail>-begda IS NOT INITIAL
        AND <detail>-endda IS NOT INITIAL.

        IF <detail>-begda > <detail>-endda.
          APPEND VALUE #(
            %key = <detail>-%key
            %msg = new_message(
              id = 'ZMSG'
              number = '000'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Invalid validity date'
            )
            %element-begda = if_abap_behv=>mk-on
            %element-endda = if_abap_behv=>mk-on
          ) TO reported-zrcompany_bank_detail.

          APPEND VALUE #(
            itemid = <detail>-itemid
            bukrs = <detail>-bukrs
          ) TO failed-zrcompany_bank_detail.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatenooverlap.
    READ ENTITIES OF zrcompany_bank IN LOCAL MODE
        ENTITY zrcompany_bank_detail
          FIELDS ( bukrs hbkid begda endda )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_new_details).

    DATA lt_existing_details TYPE TABLE OF zcompany_bank.

    READ TABLE lt_new_details ASSIGNING FIELD-SYMBOL(<new_detail>) INDEX 1.
    SELECT a~* FROM zcompany_bank AS a
       LEFT JOIN @lt_new_details AS b ON a~itemid EQ b~itemid
       WHERE a~bukrs = @<new_detail>-bukrs AND
             b~itemid IS NULL
         INTO TABLE @DATA(lt_existing).


    LOOP AT lt_new_details INTO DATA(ls_new).
      APPEND INITIAL LINE TO lt_existing ASSIGNING FIELD-SYMBOL(<fs_exist>).
      MOVE-CORRESPONDING ls_new TO <fs_exist>.
    ENDLOOP.

    LOOP AT lt_new_details ASSIGNING <new_detail>.

      LOOP AT lt_existing ASSIGNING FIELD-SYMBOL(<existing>) WHERE ( begda BETWEEN <new_detail>-begda AND <new_detail>-endda ) OR
                                                                   ( endda BETWEEN <new_detail>-begda AND <new_detail>-endda ).

        IF <new_detail>-itemid = <existing>-itemid.
          CONTINUE.
        ENDIF.

        IF NOT ( <new_detail>-endda < <existing>-begda
                 OR <new_detail>-begda > <existing>-endda ).

          APPEND VALUE #(
            %key = <new_detail>-%key
            %msg = new_message(
              id = 'ZMSG'
              number = '000'
              severity = if_abap_behv_message=>severity-error
              v1 = 'Validity Date is Cross Over with Other'
*              v2 = <existing>-endda
*              v3 = <new_detail>-bukrs
*              v4 = <new_detail>-hbkid
            )
            %element-begda = if_abap_behv=>mk-on
            %element-endda = if_abap_behv=>mk-on
          ) TO reported-zrcompany_bank_detail.

          APPEND VALUE #(
            itemid = <new_detail>-itemid
            bukrs = <new_detail>-bukrs
          ) TO failed-zrcompany_bank_detail.

          EXIT.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD check_housebank_company.
   READ ENTITIES OF ZRCOMPANY_BANK IN LOCAL MODE
    ENTITY ZRCOMPANY_BANK_detail
    FIELDS ( Bukrs Hbkid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_items).

   LOOP AT lt_items INTO DATA(ls_item).

    CHECK ls_item-Hbkid IS NOT INITIAL.

    SELECT SINGLE CompanyCode
      FROM I_HouseBank
      WHERE HouseBank = @ls_item-Hbkid AND
            CompanyCode = @ls_item-Bukrs
      INTO @DATA(lv_bukrs).

    IF sy-subrc <> 0.

      APPEND VALUE #(
        %msg = new_message(
          id       = 'ZMSG'
          number   = '000'
          severity = if_abap_behv_message=>severity-error
          v1       = ls_item-Hbkid
          v2       = ls_item-Bukrs
        )
      ) TO  reported-zrcompany_bank.

    ENDIF.

  ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zrcompany_bank DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zrcompany_bank RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zrcompany_bank RESULT result.

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR zrcompany_bank RESULT result.


    METHODS is_create_granted IMPORTING bukrs                 TYPE bukrs OPTIONAL
                              RETURNING VALUE(create_granted) TYPE abap_bool.
    METHODS is_update_granted IMPORTING bukrs                 TYPE bukrs OPTIONAL
                              RETURNING VALUE(update_granted) TYPE abap_bool.
    METHODS is_delete_granted  IMPORTING bukrs                 TYPE bukrs OPTIONAL
                               RETURNING VALUE(delete_granted) TYPE abap_bool.

ENDCLASS.

CLASS lhc_zrcompany_bank IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA: update_requested TYPE abap_bool,
          delete_requested TYPE abap_bool,
          update_granted   TYPE abap_bool,
          delete_granted   TYPE abap_bool.


    READ ENTITIES OF zrcompany_bank IN LOCAL MODE
        ENTITY zrcompany_bank
          FIELDS ( companycode )
          WITH CORRESPONDING #( keys )
      RESULT DATA(lt_bukrs)
      FAILED failed.

    CHECK lt_bukrs IS NOT INITIAL.

    LOOP AT lt_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
      IF requested_authorizations-%update                =  if_abap_behv=>mk-on OR
         requested_authorizations-%action-edit           =  if_abap_behv=>mk-on.

        IF  is_update_granted( <fs_bukrs>-companycode  ) = abap_true.
          update_granted = abap_true.
        ELSE.
          APPEND VALUE #( %tky = <fs_bukrs>-%tky
                               %msg = new_message(
                               id       = 'ZMSG'
                               number   = '000'
                               v1       = |Not authorize Update|
                               severity = if_abap_behv_message=>severity-error )
                                %global = if_abap_behv=>mk-on
                              ) TO reported-zrcompany_bank.

        ENDIF.
      ENDIF.

      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted = abap_true THEN if_abap_behv=>auth-allowed
                                                 ELSE if_abap_behv=>auth-unauthorized )
                              del_auth = COND #( WHEN delete_granted = abap_true THEN if_abap_behv=>auth-allowed
                                                 ELSE if_abap_behv=>auth-unauthorized )
                          IN
                           %tky = <fs_bukrs>-%tky
                           %update                = upd_auth
                           %action-edit           = upd_auth

                           %delete                = del_auth
                        ) TO result.
    ENDLOOP.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*  ENDMETHOD.


  METHOD is_create_granted.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'ACTVT'      FIELD '01'
    ID 'BUKRS'      FIELD bukrs.
    create_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD is_delete_granted.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'ACTVT'      FIELD '06'
      ID 'BUKRS'      FIELD bukrs.
    delete_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

  METHOD is_update_granted.
    IF bukrs NE space.
      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'ACTVT'      FIELD '02'
       ID 'BUKRS'      FIELD bukrs.
    ENDIF.
    update_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zrcompany_bank DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zrcompany_bank IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
