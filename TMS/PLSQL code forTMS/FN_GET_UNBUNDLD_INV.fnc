DROP FUNCTION SCD.FN_GET_UNBUNDLD_INV;

CREATE OR REPLACE FUNCTION SCD.FN_GET_UNBUNDLD_INV (I_DISTR_BUS IN NUMBER, I_BILL_PERIOD_DT IN  DATE, I_CTGY_CD IN VARCHAR2 ) RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       FN_GET_UNBUNDLD_INV
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        9/16/2016   Z919520       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_GET_UNBUNDLD_INV
      Sysdate:         9/16/2016
      Date and Time:   9/16/2016, 2:39:53 PM, and 9/16/2016 2:39:53 PM
      Username:        Z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

V_BUS_ENTY_ID NUMBER(9);
V_INV_ID NUMBER(9);

BEGIN
   tmpVar := 0;
   BEGIN
   SELECT CARR_BUS_ENTY_ID INTO V_BUS_ENTY_ID  FROM TEMP_CARR_INV_TYPE
   WHERE DISTR_PNT_BUS_ENTY_ID = I_DISTR_BUS 
   AND INV_TYPE = 'UNBUNDLED'
   AND REF_COST LIKE '%'||I_CTGY_CD || '%';
   END;
   
   BEGIN
   SELECT INV_ID INTO V_INV_ID FROM CARR_INV 
WHERE CARR_BUS_ENTY_ID =    V_BUS_ENTY_ID
AND  DISTR_PNT_BUS_ENTY_ID = I_DISTR_BUS
AND BILL_PERIOD_START_DT = I_BILL_PERIOD_DT;
   END; 
   DBMS_OUTPUT.PUT_LINE('V_INV_ID : ' || V_INV_ID);
   RETURN V_INV_ID;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       V_INV_ID := NULL;
     WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('V_INV_ID : ' || SQLERRM);
       -- Consider logging the error and then re-raise
       V_INV_ID := NULL;
       DBMS_OUTPUT.PUT_LINE('V_INV_ID : ' || SQLERRM);
END FN_GET_UNBUNDLD_INV;
/
