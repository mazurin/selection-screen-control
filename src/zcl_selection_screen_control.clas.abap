class ZCL_SELECTION_SCREEN_CONTROL definition
  public
  create public .

public section.

  data:
    " Класс предназначен для организации гибкой обработки видимости и обязательности полей
    " на селекционном экране программы
    " Для использования необходимо:
    " 1. В программе создать класс наследник, в котором переопределить методы  IS_READ_ONLY, IS_NO_INPUT, IS_INVISIBLE:
    "   - метод IS_READ_ONLY должен возвращать ABAP_TRUE в случае если ввод в поле должен быть запрещён
    "   - метод IS_NO_INPUT должен возвращать ABAP_TRUE в случае если ввод и ОТОБРАЖЕНИЕ данных
    "     в поле не должно выполняться (не путать с IS_READ_ONLY!). В этом режиме поле выводится на экран пустым
    "     без возможности ввода значения
    "   - метод IS_INVISIBLE должен возвращать ABAP_TRUE в случае, если поле должно быть скрыто на экране
    " 2. Сделать вызов метода PBO в событии AT SELECTION SCREEN OUTPUT
    " 3. Сделать вызов метода PAI в событии AT SELECTION
    "
    " Для того чтобы заданные разработчиком события на экране не прерывались проверкой обязательности,
    " их коды должны начинаться на ZZ, либо добавлены в MR_NO_OBLIGATORY_CHECK_UCOMM
      "! События экрана для которых не будет выполняться проверка обязательности заполнения полей
    mr_no_obligatory_check_ucomm TYPE RANGE OF sy-ucomm read-only .

  methods CONSTRUCTOR .
  methods PBO
  final .
  methods PAI
  final .
protected section.

  constants:
    BEGIN OF c_s_screen_group,
        parameter TYPE screen-group3 VALUE 'PAR',
        low       TYPE screen-group3 VALUE 'LOW',
        high      TYPE screen-group3 VALUE 'HGH',
      END OF c_s_screen_group .
  constants:
    BEGIN OF c_s_attr_activity,
        _0 TYPE c LENGTH 1 VALUE '0',
        _1 TYPE c LENGTH 1 VALUE '1',
        _2 TYPE c LENGTH 1 VALUE '2',
      END OF c_s_attr_activity .

  methods IS_INVISIBLE
    importing
      !IS_SCREEN type SCREEN
    returning
      value(RV_INVISIBLE) type ABAP_BOOL .
  methods IS_NO_INPUT
    importing
      !IS_SCREEN type SCREEN
    returning
      value(RV_NO_INPUT) type ABAP_BOOL .
  methods IS_READ_ONLY
    importing
      !IS_SCREEN type SCREEN
    returning
      value(RV_READ_ONLY) type ABAP_BOOL .
  methods MODIFY_SCREEN
    changing
      !CS_SCREEN type SCREEN .
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ts_obligatory_fields,
        dynnr       TYPE sy-dynnr,
        order       TYPE i,
        screen_name TYPE screen-name,
        field       TYPE char80,
      END OF ts_obligatory_fields .
    DATA:
      "! Список обязательных для ввода полей
      mt_obligatory_fields TYPE SORTED TABLE OF ts_obligatory_fields WITH NON-UNIQUE KEY dynnr order .
ENDCLASS.



CLASS ZCL_SELECTION_SCREEN_CONTROL IMPLEMENTATION.


  METHOD constructor.
    " Класс предназначен для организации гибкой обработки видимости и обязательности полей
    " на селекционном экране программы
    " Для использования необходимо:
    " 1. В программе создать класс наследник, в котором переопределить методы  IS_READ_ONLY, IS_NO_INPUT, IS_INVISIBLE:
    "   - метод IS_READ_ONLY должен возвращать ABAP_TRUE в случае если ввод в поле должен быть запрещён
    "   - метод IS_NO_INPUT должен возвращать ABAP_TRUE в случае если ввод и ОТОБРАЖЕНИЕ данных
    "     в поле не должно выполняться (не путать с IS_READ_ONLY!). В этом режиме поле выводится на экран пустым
    "     без возможности ввода значения
    "   - метод IS_INVISIBLE должен возвращать ABAP_TRUE в случае, если поле должно быть скрыто на экране
    " 2. Сделать вызов метода PBO в событии AT SELECTION SCREEN OUTPUT
    " 3. Сделать вызов метода PAI в событии AT SELECTION
    "
    " Для того чтобы заданные разработчиком события на экране не прерывались проверкой обязательности,
    " их коды должны начинаться на ZZ, либо добавлены в MR_NO_OBLIGATORY_CHECK_UCOMM
    super->constructor( ).
    " События экрана для которых не будет выполняться проверка обязательности заполнения полей
    " Не обрабатываем команды переключения радиокнопок, нажатие Enter, вызов варианта, все ZZ команды
    " Список может быть дополнен в конструкторе класса наследника
    mr_no_obligatory_check_ucomm = VALUE #(
                                       ( sign = rs_c_range_sign-including option = rs_c_range_opt-equal   low = space )    " нажатие Enter
                                       ( sign = rs_c_range_sign-including option = rs_c_range_opt-equal   low = 'OPTI' )   " вызов варианта
                                       ( sign = rs_c_range_sign-including option = rs_c_range_opt-pattern low = 'ZZ*' )    " все ZZ команды
                                       ( sign = rs_c_range_sign-including option = rs_c_range_opt-pattern low = 'FC0+' )   " нажатия кнопок заданных через SELECTION-SCREEN FUNCTION KEY
                                       ( sign = rs_c_range_sign-including option = rs_c_range_opt-pattern low = '%*' ) ).  " нажатия кнопок ввода диапазонов значений в SELECT-OPTION
  ENDMETHOD.


  METHOD is_invisible.
    " Метод может быть переопределён в классе наследнике
    " метод is_invisible должен возвращать abap_true в случае, если поле должно быть скрыто на экране
    rv_invisible = abap_false.
  ENDMETHOD.


  METHOD is_no_input.
    " Метод может быть переопределён в классе наследнике
    " метод IS_NO_INPUT должен возвращать ABAP_TRUE в случае если ввод и ОТОБРАЖЕНИЕ данных
    " в поле не должно выполняться (не путать с IS_READ_ONLY!). В этом режиме поле выводится на экран пустым
    " без возможности ввода значения
    rv_no_input = abap_false.
  ENDMETHOD.


  METHOD is_read_only.
    " Метод может быть переопределён в классе наследнике
    " метод IS_READ_ONLY должен возвращать ABAP_TRUE в случае если ввод в поле должен быть запрещён
    rv_read_only = abap_false.
  ENDMETHOD.


  METHOD modify_screen.
    " В наследнике класса можно изменить атрибуты поля экрана
    " Пример:
    " IF cs_screen-name = 'P_VALUE' AND
    "    p_obl = abap_true.
    "   cs_screen-required = '1'.  " <- поле станет обязательным
    " ENDIF.
  ENDMETHOD.


  METHOD pai.
    FIELD-SYMBOLS <ls_sscrfields> TYPE sscrfields.
    DATA(lv_fld) = |({ sy-cprog })SSCRFIELDS|.
    ASSIGN (lv_fld) TO <ls_sscrfields>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
    " Ручное управление обязательностью полей в PAI
    DATA(lv_save_ucomm) = <ls_sscrfields>-ucomm.
    IF <ls_sscrfields>-ucomm NOT IN mr_no_obligatory_check_ucomm.
      " Сбросим команду на случай ошибки
      CLEAR <ls_sscrfields>-ucomm.
      " Ручная проверка на обязательность заполнения полей
      LOOP AT mt_obligatory_fields REFERENCE INTO DATA(lref_field)
          USING KEY primary_key
          WHERE dynnr = sy-dynnr.
        ASSIGN (lref_field->field) TO FIELD-SYMBOL(<lv_screen_field>).
        " Если поле пустое, то установим курсор на него и выведем MESSAGE о необходимости заполнения
        IF sy-subrc = 0 AND <lv_screen_field> IS INITIAL.
          SET CURSOR FIELD lref_field->screen_name.
          MESSAGE e055(00).
        ENDIF.
      ENDLOOP.
    ENDIF.
    <ls_sscrfields>-ucomm = lv_save_ucomm.
  ENDMETHOD.


  METHOD pbo.
    DELETE mt_obligatory_fields USING KEY primary_key WHERE dynnr = sy-dynnr.
    " Ручное управление обязательностью полей в PBO
    DATA(lv_pos) = 0.
    LOOP AT SCREEN INTO DATA(ls_screen).
      lv_pos += 1.
      modify_screen(
        CHANGING
          cs_screen = ls_screen ).
      IF is_invisible( ls_screen ).
        " Поле невидимо
        ls_screen-input     = c_s_attr_activity-_0.
        ls_screen-invisible = c_s_attr_activity-_1.
      ELSEIF is_no_input( ls_screen ).
        " Поле без отображения значения
        ls_screen-input = c_s_attr_activity-_0.
        IF ls_screen-group3 = c_s_screen_group-parameter OR
           ls_screen-group3 = c_s_screen_group-low OR
           ls_screen-group3 = c_s_screen_group-high.
          ls_screen-output = c_s_attr_activity-_0.
        ENDIF.
      ELSEIF is_read_only( ls_screen ).
        " Поле только для чтения
        ls_screen-input = c_s_attr_activity-_0.
      ENDIF.
      IF ls_screen-required = c_s_attr_activity-_1 AND
         ls_screen-input    = c_s_attr_activity-_1.
        " Если поле экрана OBLIGATORY и доступно для ввода, то включим его в список ручной обработки обязательности
        CASE ls_screen-group3.
          WHEN c_s_screen_group-low.
            SPLIT ls_screen-name AT '-' INTO DATA(lv_field) DATA(lv_dummy).
            INSERT VALUE #(
                       dynnr       = sy-dynnr
                       order       = lv_pos
                       screen_name = ls_screen-name
                       field       = |({ sy-cprog }){ lv_field }[]| ) INTO TABLE mt_obligatory_fields.
          WHEN c_s_screen_group-parameter.
            INSERT VALUE #(
                       dynnr       = sy-dynnr
                       order       = lv_pos
                       screen_name = ls_screen-name
                       field       = |({ sy-cprog }){ ls_screen-name }| ) INTO TABLE mt_obligatory_fields.
          WHEN OTHERS.
        ENDCASE.
        ls_screen-required = c_s_attr_activity-_2.
      ENDIF.
      MODIFY SCREEN FROM ls_screen.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
