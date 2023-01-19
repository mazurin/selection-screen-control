*&---------------------------------------------------------------------*
*& Report zdemo_selection_screen_control
*&---------------------------------------------------------------------*
*& Demonstration of using the ZCL_SELECTION_SCREEN_CONTROL class
*&---------------------------------------------------------------------*
REPORT zdemo_selection_screen_control.

DATA:
  BEGIN OF gs_so_params,
    param1 TYPE char30,
    param3 TYPE char30,
    param5 TYPE char30,
  END OF gs_so_params.

CLASS lcl_selscr DEFINITION DEFERRED.
DATA go_ssrc TYPE REF TO lcl_selscr.

SELECTION-SCREEN BEGIN OF BLOCK bl01 WITH FRAME TITLE TEXT-001.
  PARAMETERS p_test0 RADIOBUTTON GROUP gr1 USER-COMMAND zz_var.
  PARAMETERS p_test1 RADIOBUTTON GROUP gr1.
  PARAMETERS p_test2 RADIOBUTTON GROUP gr1.
  PARAMETERS p_test3 RADIOBUTTON GROUP gr1.

  SELECTION-SCREEN SKIP.

  PARAMETERS p_var1 AS CHECKBOX USER-COMMAND zz_cb.
  PARAMETERS p_var2 AS CHECKBOX USER-COMMAND zz_cb.
  PARAMETERS p_var3 AS CHECKBOX USER-COMMAND zz_cb.

  SELECTION-SCREEN SKIP.

  PARAMETERS p_oblig4 AS CHECKBOX USER-COMMAND zz_var.

  SELECTION-SCREEN ULINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS p_off AS CHECKBOX USER-COMMAND zz_cb.
    SELECTION-SCREEN COMMENT (60) TEXT-003 FOR FIELD p_off .
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl01.

SELECTION-SCREEN BEGIN OF BLOCK bl02 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS s_param1 FOR gs_so_params-param1 OBLIGATORY DEFAULT sy-abcde(5)    MODIF ID g01.
  PARAMETERS p_param2 TYPE text30                 OBLIGATORY                        MODIF ID g01.
  SELECT-OPTIONS s_param3 FOR gs_so_params-param3 OBLIGATORY DEFAULT sy-abcde+6(5)  MODIF ID g02.
  PARAMETERS p_param4 TYPE text30                                                   MODIF ID g02.
  SELECT-OPTIONS s_param5 FOR gs_so_params-param5 OBLIGATORY DEFAULT sy-abcde+12(5) MODIF ID g03.
  PARAMETERS p_param6 TYPE text30 DEFAULT sy-abcde+15(5)                            MODIF ID g03.
SELECTION-SCREEN END OF BLOCK bl02.

CLASS lcl_selscr DEFINITION
    INHERITING FROM zcl_selection_screen_control.

  PROTECTED SECTION.
    METHODS is_invisible  REDEFINITION.
    METHODS is_no_input   REDEFINITION.
    METHODS is_read_only  REDEFINITION.
    METHODS modify_screen REDEFINITION.
ENDCLASS.

CLASS lcl_selscr IMPLEMENTATION.
  METHOD is_invisible.
    rv_invisible = xsdbool( p_var3           = abap_on AND
                            is_screen-group1 = 'G03' ).
  ENDMETHOD.

  METHOD is_no_input.
    rv_no_input = xsdbool( p_var1           = abap_on AND
                           is_screen-group1 = 'G01' ).
  ENDMETHOD.

  METHOD is_read_only.
    rv_read_only = xsdbool( p_var2           = abap_on AND
                            is_screen-group1 = 'G02' ).
  ENDMETHOD.

  METHOD modify_screen.
    IF cs_screen-name = 'P_PARAM4' AND
       p_oblig4       = abap_true.
      cs_screen-required = '1'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

INITIALIZATION.
  go_ssrc = NEW #( ).
  SUPPRESS DIALOG.

AT SELECTION-SCREEN OUTPUT.
  IF p_off = abap_false.
    go_ssrc->pbo( ).
  ENDIF.

AT SELECTION-SCREEN.
  IF p_off = abap_false.
    go_ssrc->pai( ).
  ENDIF.
