CREATE OR REPLACE FUNCTION SCD.FN_MULE_GET_INV_UP(P_INV_ID  IN NUMBER, P_CTGRY_CD IN VARCHAR2) RETURN NUMBER IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       FN_MULE_GET_INV_UP
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8/19/2016   z919520       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_MULE_GET_INV_UP
      Sysdate:         8/19/2016
      Date and Time:   8/19/2016, 2:47:57 PM, and 8/19/2016 2:47:57 PM
      Username:        z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
V_UNIT_PRICE NUMBER;
V_DTL_AMT NUMBER(9,2);
V_DTL_AMT_UN NUMBER(9,2);
V_OP_AMT NUMBER(9,2);
V_CNT_VRBMLG number;
BEGIN
      IF P_CTGRY_CD = 'ADMIN' THEN
      dbms_output.put_line('inside admin');
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('DRVRCHG',
'FRTADJMNT',
'GENEXP',
'GEN_SPOTTING',
'LABOR',
'LABOR-DUMP/REPK',
'MISC-CHARGES',
'OVERTIME-LABOR',
'SGLTRDRV',
'SLPTRDRV',
'STOPOFF-CHG',
'TOLLCHG',
'UNKNOWN'
) ;
    
--SELECT SUM(DTL_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'DRIVERBBQ' , 'FXDWKLLOC8' , 'FXDWKLLOC9' , 'FXDWLLOC10'
--, 'FXDWLLOC11' , 'FXDWLLOC12' , 'FXDWLLOC13' , 'GCILCHG'
--, 'HANDELING' , 'MISC' , 'MISC CHARGE' , 'MISC CHG'
--, 'MISCEXPENSE' , 'MISCOPSUP' , 'MOTEL' , 'NOLOADCHG'
--, 'NYZIPCHRG' , 'PARKING' , 'R/SDUNNAGE' , 'RAC ADJUST'
--, 'REDEIVERY' , 'REDELIVERY' , 'RM-211952'
--, 'RM-212115' , 'RMRCANLOADS' , 'SHUTTLE'
--, 'SLPRCBHR' , 'SPOTTERFEE' , 'STOPOFF'
--, 'TOLLS' , 'TRAILER DAMAGE' , 'TRAILERDAMAGE'
--, 'TRL DAMAGE' ,'TRL DAMAGES' , 'TRL-RETRIEVALS'
--, 'TRLDAMAGES' , 'TRLPICKUPS' , 'TRLRDAMAG'
--, 'TRLRECOVERY' ,  'TRLREPAIR' , 'TRLREPAIRS'
--, 'TRLRETRIEVAL' , 'TRLRETRIEVALS' , 'TURNAROUND' 
--) ;
dbms_output.put_line('inside admin' || V_DTL_AMT || '- ' || V_DTL_AMT_UN);
V_OP_AMT := nvl(V_DTL_AMT,0);
END IF;
  
  IF P_CTGRY_CD = 'FUEL' THEN
      
      SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('FUELSURCHG',
'FUEL_TAX'
) ;
    
--SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'FINDLAY LN FSC',
--'FUEL',
--'FUELSURTR'
--) ;

V_OP_AMT := nvl(V_DTL_AMT,0); -- + nvl(V_DTL_AMT_UN,0);
END IF;
  

  IF P_CTGRY_CD = 'MILEAGE' THEN
      

      SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('VARBLMLG') ;
   
--SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'FIXED',
--'MILEAGE',
--'VARBLTRLMLG'
--) ;

V_OP_AMT := nvl(V_DTL_AMT,0) ; --+ nvl(V_DTL_AMT_UN,0);
END IF;

 IF P_CTGRY_CD = 'TRACTOR' THEN
      
      SELECT SUM(dtl_amt) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('CHGDAYCAB',
'SLIPTRCT',
'SLPRCBCHR',
'SGLTRCTOR'
) ;
    
V_OP_AMT := nvl(V_DTL_AMT,0);
END IF;

  IF P_CTGRY_CD = 'TRAILER' THEN
      
      SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('DRYVANTR',
'LEASED-TRLR-CHG',
'PLATETRL53',
'REFRTR53',
'ROLLERBEDTRL'
) ;
    
--SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'JAN TRL RENTAL',
--'TEST TRAILER',
--'TRLRENTALS'
--) ;

V_OP_AMT := nvl(V_DTL_AMT,0); -- + nvl(V_DTL_AMT_UN,0);
END IF;

IF P_CTGRY_CD = 'CNG' THEN
      
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('CNG_CONV_FCTR',
'CNG_FIXED_COMP',
'CNG_FIXED_ELEC',
'CNG_FIXED_MAINT',
'CNG_FIXED_MGT',
'CNG_FIXED_RE',
'CNG_INDEX_PRICE',
'GGE_PURCHASED'
) ;
    
--SELECT SUM(DTL_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'CNG_FIXED_PIPE'
--) ;

V_OP_AMT := nvl(V_DTL_AMT,0); -- + nvl(V_DTL_AMT_UN,0);
END IF;

 IF P_CTGRY_CD = 'LEASE' THEN
      
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('CNGTRCTOR'
) ;
    
V_OP_AMT := nvl(V_DTL_AMT,0);
END IF;

 IF P_CTGRY_CD = 'MAINT' THEN
      
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('CNG MLG'
) ;
    
V_OP_AMT := nvl(V_DTL_AMT,0) ;
END IF;

 IF P_CTGRY_CD = 'BACKHAUL' THEN
      
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID 
      AND INV_CTGY_CD IN
       ('BACKHAULCR',
'BALER',
'BHFUELCR',
'INBOUNDMATCR'
) ;
  
--SELECT SUM(DTL_AMT) INTO V_DTL_AMT_UN FROM CARR_INV_DTL 
--       WHERE INV_ID = P_INV_ID 
--      AND INV_CTGY_CD = 'UNKNOWN'
--      AND UNKNOWN_CTGY_CD IN
--       ( 'BKHFLREVCR'
--) ;

V_OP_AMT := nvl(V_DTL_AMT,0); -- + nvl(V_DTL_AMT_UN,0);

END IF;

   RETURN V_OP_AMT;
   EXCEPTION
     WHEN OTHERS THEN
       V_OP_AMT := NULL;
       -- Consider logging the error and then re-raise
      -- RAISE;
END FN_MULE_GET_INV_UP;
/
