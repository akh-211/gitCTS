CLASS lhc_upload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS uploadexcel FOR MODIFY
      IMPORTING keys FOR ACTION upload~uploadexcel.

ENDCLASS.

CLASS lhc_upload IMPLEMENTATION.

  METHOD uploadexcel.
    TYPES : BEGIN OF ty_sheet_data,
              company_code               TYPE string, "zcl_timesheet_api=>tys_time_sheet_entry-company_code,
              person_work_agreement_exte TYPE string, "zcl_timesheet_api=>tys_time_sheet_entry-person_work_agreement_exte,
              time_sheet_date            TYPE string, "zcl_timesheet_api=>tys_time_sheet_entry-time_sheet_date,
              recorded_hours             TYPE string, "zcl_timesheet_api=>tys_time_sheet_data_fields-recorded_hours,
              receiver_cost_center       TYPE string, "zcl_timesheet_api=>tys_time_sheet_data_fields-receiver_cost_center,
              task_type                  TYPE string, "zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_type,
              task_level                 TYPE string, "zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_level,
              task_component             TYPE string, "zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_component,
            END OF ty_sheet_data.


    TYPES : BEGIN OF ty_data,
              company_code               TYPE zcl_timesheet_api=>tys_time_sheet_entry-company_code,
              person_work_agreement_exte TYPE zcl_timesheet_api=>tys_time_sheet_entry-person_work_agreement_exte,
              time_sheet_date            TYPE zcl_timesheet_api=>tys_time_sheet_entry-time_sheet_date,
              recorded_hours             TYPE zcl_timesheet_api=>tys_time_sheet_data_fields-recorded_hours,
              receiver_cost_center       TYPE zcl_timesheet_api=>tys_time_sheet_data_fields-receiver_cost_center,
              task_type                  TYPE zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_type,
              task_level                 TYPE zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_level,
              task_component             TYPE zcl_timesheet_api=>tys_time_sheet_data_fields-time_sheet_task_component,
            END OF ty_data.

    DATA lv_file_content   TYPE xstring.
    DATA lt_sheet_data     TYPE STANDARD TABLE OF ty_sheet_data.
    DATA lt_data     TYPE STANDARD TABLE OF ty_data.
    DATA lw_data     TYPE ty_data.
    DATA lt_listing_create TYPE TABLE FOR CREATE zr_timesheet_upl2.
    DATA lx_exception TYPE REF TO cx_root.
    DATA lv_cc TYPE I_CostCenter-CostCenter.

    CLEAR lx_exception.
    CLEAR lt_data[].
    TRY.
        lv_file_content = VALUE #( keys[ 1 ]-%param-_streamproperties-streamproperty OPTIONAL ).

        " Error handling in case file content is initial

        DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( lv_file_content )->read_access( ).

        DATA(lo_worksheet) = lo_document->get_workbook( )->worksheet->at_position( 1 ).

        DATA(o_sel_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
*          )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )  " Start reading from Column A
*          )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'H' )   " End reading at Column N
          )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )    " *** Start reading from ROW 2 to skip the header ***
          )->get_pattern( ).

        lo_worksheet->select( o_sel_pattern
                                         )->row_stream(
                                         )->operation->write_to( REF #( lt_sheet_data )
                                         )->set_value_transformation(
                                             xco_cp_xlsx_read_access=>value_transformation->string_value
                                          )->execute( ).

      CATCH cx_root INTO lx_exception.
        APPEND VALUE #(
                         %cid = keys[ 1 ]-%cid
                         %msg = new_message(
                           id       = '0'
                           number   = '000'
                           v1       = |Error phares excel {  lx_exception->get_text( ) }|
                           severity = if_abap_behv_message=>severity-error )
                       ) TO reported-upload.

        APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
    ENDTRY.
*    IF failed IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_listing_create ASSIGNING FIELD-SYMBOL(<fs>).
    <fs>-filename = VALUE #( keys[ 1 ]-%param-_streamproperties-filename OPTIONAL ).

    CONSTANTS lc_excel_epoch TYPE d VALUE '18991231'. " Day 0
    CONSTANTS lc_leap_bug_day TYPE i VALUE 60. " Excel's fake 29-Feb-1900

    SELECT * FROM i_companycode INTO TABLE @DATA(lt_comp).
    SELECT * FROM i_costcenter INTO TABLE @DATA(lt_cost).

    LOOP AT lt_sheet_data INTO DATA(ls_sheet_data).
      TRY.
          MOVE-CORRESPONDING ls_sheet_data TO lw_data.

          DATA lv_days TYPE i.
          DATA lv_date TYPE d.

          " Validate input
          IF ls_sheet_data-time_sheet_date IS INITIAL OR ls_sheet_data-time_sheet_date < 1.
            APPEND VALUE #(
                  %cid = keys[ 1 ]-%cid
                  %msg = new_message(
                    id       = '0'
                    number   = '000'
                    v1       = |Line { sy-tabix + 1 } Invalid Value Date|
                    severity = if_abap_behv_message=>severity-error )
                ) TO reported-upload.

            APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
*            CONTINUE.
          ENDIF.

          " Convert to integer days
          lv_days = floor( ls_sheet_data-time_sheet_date ).

          " Adjust for Excel leap year bug
          IF lv_days > lc_leap_bug_day.
            lv_days = lv_days - 1.
          ENDIF.

          " Add days to epoch
          lv_date = lc_excel_epoch + lv_days.
          ls_sheet_data-time_sheet_date = |{ lv_date }000000|.

          lw_data-time_sheet_date = ls_sheet_data-time_sheet_date.

          READ TABLE lt_comp TRANSPORTING NO FIELDS WITH KEY companycode = lw_data-company_code.
          IF sy-subrc NE 0.
            APPEND VALUE #(
                              %cid = keys[ 1 ]-%cid
                              %msg = new_message(
                                id       = '0'
                                number   = '000'
                                v1       = |Line { sy-tabix + 1 }|
                                v2       = |Company Code { lw_data-company_code } not Maintain|
                                severity = if_abap_behv_message=>severity-error )
                            ) TO reported-upload.

            APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
          ENDIF.

          clear lv_cc.
          lv_cc = |{ lw_data-receiver_cost_center ALPHA = IN }|.
          READ TABLE lt_cost TRANSPORTING NO FIELDS WITH KEY costcenter = lv_cc.
          IF sy-subrc NE 0.
            APPEND VALUE #(
                             %cid = keys[ 1 ]-%cid
                             %msg = new_message(
                               id       = '0'
                               number   = '000'
                               v1       = |Line { sy-tabix + 1 }|
                               v2       = |Cost Center { lw_data-receiver_cost_center } not Maintain|
                               severity = if_abap_behv_message=>severity-error )
                           ) TO reported-upload.

            APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
          ENDIF.
          APPEND lw_data TO lt_data.


        CATCH cx_root INTO lx_exception.
          APPEND VALUE #(
                           %cid = keys[ 1 ]-%cid
                           %msg = new_message(
                             id       = '0'
                             number   = '000'
                             v1       = |Line { sy-tabix + 1 }|
                             v2       = lx_exception->get_text( )
                             severity = if_abap_behv_message=>severity-error )
                         ) TO reported-upload.

          APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
      ENDTRY.
    ENDLOOP.

*    ENDIF.

    DATA:
      ls_business_data        TYPE zcl_timesheet_api=>tys_time_sheet_entry,
      lt_employee             TYPE TABLE OF  zcl_timesheet_api=>tys_time_sheet_entry,
      ls_business_data_fields TYPE zcl_timesheet_api=>tys_time_sheet_data_fields,
      lo_create_request       TYPE REF TO /iwbep/if_cp_request_create,
      lo_batch_request        TYPE REF TO /iwbep/if_cp_request_batch,
      lo_changeset_request    TYPE REF TO /iwbep/if_cp_request_changeset,
      lo_read_request         TYPE REF TO /iwbep/if_cp_request_read_list,
      lo_create_response      TYPE REF TO /iwbep/if_cp_response_create,
      lo_read_response        TYPE REF TO /iwbep/if_cp_response_read_lst,
      lo_http_client          TYPE REF TO if_web_http_client,
      lo_client_proxy         TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_response             TYPE REF TO /iwbep/if_cp_response_create.

    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'ZCS_TIMESHEET' ).
        "service_id = 'ZTIMESHEET_REST' ).

        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'ZCL_TIMESHEET_API'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = ''
            ).

        ASSERT lo_http_client IS BOUND.

        lo_batch_request = lo_client_proxy->create_request_for_batch( ).
        lo_changeset_request = lo_batch_request->create_request_for_changeset( ).

        LOOP AT lt_data INTO DATA(ls_data).

* Prepare business data fields
          ls_business_data_fields = VALUE #(
              receiver_cost_center        = ls_data-receiver_cost_center
              recorded_hours              = ls_data-recorded_hours
              time_sheet_task_type        = ls_data-task_type
              time_sheet_task_level       = ls_data-task_level
              time_sheet_task_component   = ls_data-task_component
           ).

* Prepare business data
          ls_business_data = VALUE #(
                   person_work_agreement_exte  = ls_data-person_work_agreement_exte
                   company_code                = ls_data-company_code
                   "time_sheet_record           = 'TimeSheetRecord'
                   "person_work_agreement       = '50000001'
                   time_sheet_date             = ls_data-time_sheet_date"
                   "time_sheet_is_released_on   = abap_true
                   "time_sheet_predecessor_rec  = 'TimeSheetPredecessorRec'
                   "time_sheet_status           = 'TimeSheetStatus'
                   "time_sheet_is_executed_in   = abap_true
                   time_sheet_operation        = 'C'
                   time_sheet_data_fields      =  ls_business_data_fields ).
*          ENDIF..
          " Navigate to the resource and create a request for the create operation
          lo_create_request = lo_client_proxy->create_resource_for_entity_set( 'TIME_SHEET_ENTRY_COLLECTIO' )->create_request_for_create( ).

          " Set the business data for the created entity
          lo_create_request->set_business_data( ls_business_data ).
          lo_changeset_request->add_request( lo_create_request ).
        ENDLOOP.

        lo_batch_request->add_request( lo_changeset_request ).

        lo_batch_request->execute( ).

        lo_batch_request->check_execution( ).
*        lo_read_response  = lo_read_request->get_response( ).
*        lo_read_response->get_business_data( IMPORTING et_business_data = lt_employee ).

*        lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

      CATCH cx_root INTO lx_exception.
        APPEND VALUE #(
            %cid = keys[ 1 ]-%cid
            %msg = new_message(
              id       = '0'
              number   = '000'
              v1       = |Error API Execution: { lx_exception->get_text( ) }|
              severity = if_abap_behv_message=>severity-error )
          ) TO reported-upload.

        APPEND VALUE #( %cid = keys[ 1 ]-%cid ) TO failed-upload.
        RETURN.
    ENDTRY.



    MODIFY ENTITIES OF zr_timesheet_upl2 IN LOCAL MODE
              ENTITY upload
              CREATE AUTO FILL CID FIELDS ( filename failed status succes  )
              WITH lt_listing_create
              " TODO: variable is assigned but never used (ABAP cleaner)
              MAPPED DATA(lt_mapped)
              " TODO: variable is assigned but never used (ABAP cleaner)
              REPORTED DATA(lt_reported)
              " TODO: variable is assigned but never used (ABAP cleaner)
              FAILED DATA(lt_failed).

  ENDMETHOD.

ENDCLASS.
