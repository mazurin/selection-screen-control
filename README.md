# selection-screen-control
Controlling the visibility of fields on the selection screen of abap program

The class is designed to organize flexible processing of the visibility and mandatory fields on the selection screen of the abap program
To use it is necessary:
1. Create a successor class in the program, in which, if necessary, override the IS_READ_ONLY, IS_NO_INPUT, IS_INVISIBLE methods. These methods are called in the LOOP AT SCREEN loop for each screen field.
   - IS_READ_ONLY method should return ABAP_TRUE if input in the field should be prohibited
   - IS_NO_INPUT method should return ABAP_TRUE if the input and DISPLAY of data in the field should not be performed (not to be confused with IS_READ_ONLY!). In this mode, the field is displayed empty without the possibility of entering a value.
   - IS_INVISIBLE method should return ABAP_TRUE in case the field should be hidden on the screen
2. Make a PBO method call in the AT SELECTION SCREEN OUTPUT event
3. Make a PAI method call in the AT SELECTION event
