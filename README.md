# Abap selection screen control
Control the appearance of fields on the abap program selection screen

The class is made to facilitate flexible processing of the obligatory and visible fields on the abap program selection screen. To use it, you must:
1. In the program, make a successor class and, if necessary, override the IS_READ_ONLY, IS_NO_INPUT, and IS_INVISIBLE methods in it. The LOOP AT SCREEN calls these methods once for each screen field.
- If input into the field is to be banned, the IS_READ_ONLY method should return ABAP_TRUE.
- If the entry and display of data in the field should not be performed, the IS_NO_INPUT method should return ABAP_TRUE (not to be confused with IS_READ_ONLY!). Without the ability to enter a value, the field is displayed empty in this mode.
- If the field should be hidden on the screen, the IS_INVISIBLE function should return ABAP_TRUE.
2. At the AT SELECTION SCREEN OUTPUT event, call the PBO method.
3. At the AT SELECTION event, call the PAI method.
