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
DROP FUNCTION SCD.FN_MULE_CHECK_VALID_INV;

CREATE OR REPLACE FUNCTION SCD.FN_MULE_CHECK_VALID_INV(P_INV_ID IN NUMBER, p_inv_type in varchar2) RETURN NUMBER IS

/******************************************************************************
   NAME:       FN_MULE_CHECK_VALID_INV
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        9/23/2016   Z919520       1. Created this function.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     FN_MULE_CHECK_VALID_INV
      Sysdate:         9/23/2016
      Date and Time:   9/23/2016, 1:31:36 PM, and 9/23/2016 1:31:36 PM
      Username:        Z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
v_valid_flag number;
v_calc_value number(11,2);
v_actual_value number(11,2);
--v_admin_flag number;
--v_mileage_flag number;
--v_fuel_flag number;
--v_tractor_flag number;
--v_trailer_flag number;
--v_cng_flag number;
--v_maint_flag number;
--v_lease_flag number;
BEGIN
--Check Admin Cost
begin 
select Round(sum(nvl(admin_cost,0)))  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'ADMIN', '', 'V')) ;
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--Check Mileage Cost
begin 
select Round(sum(nvl(MILGE_cost,0)))  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'MILEAGE', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--CHECK FUEL COST 

begin 
select Round(sum(nvl(FUEL_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value := Round( FN_MULE_GET_INV_UP(p_inv_id, 'FUEL', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--CHECK BACKHAUL COST
begin 
select Round(sum(nvl(BCKHAUL_cost,0)))  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  ROUND(FN_MULE_GET_INV_UP(p_inv_id, 'BACKHAUL', '', 'V') );
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--CHECK TRACTOR COST
begin 
select Round(sum(nvl(TRCTR_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'TRACTOR', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--CHECK TRailer cost
begin 
select Round(sum(nvl(TRALR_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'TRAILER', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

IF p_inv_type = 'U' THEN
--check CNG cost
begin 
select Round(sum(nvl(CNG_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'CNG', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--check Lease Cost
begin 
select Round(sum(nvl(LEASE_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'LEASE', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;

--check Miant Cost
begin 
select Round(sum(nvl(MAINT_cost,0)) )  into v_calc_value from TEMP_CARR_MULE_COST_ALLOC_DTLS
where inv_id = p_inv_id;
end;
v_actual_value :=  Round(FN_MULE_GET_INV_UP(p_inv_id, 'MAINT', '', 'V'));
if v_actual_value = v_calc_value then
v_valid_flag := 1;
else
v_valid_flag := 0;
return v_valid_flag;
end if;
END IF;

return v_valid_flag;

   EXCEPTION
     WHEN OTHERS THEN
        dbms_output.put_line('INSIDE CHECK INV : ' || SQLERRM);
        v_valid_flag := 0;
        return v_valid_flag; 
       END FN_MULE_CHECK_VALID_INV;
/
DROP FUNCTION SCD.FN_MULE_GET_INV_UP;

CREATE OR REPLACE FUNCTION SCD.FN_MULE_GET_INV_UP(P_INV_ID  IN VARCHAR2, P_CTGRY_CD IN VARCHAR2, P_DISTR_BUS IN NUMBER, P_CALC_VLDN IN VARCHAR2) RETURN NUMBER IS
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
--V_UNIT_PRICE NUMBER;
V_DTL_AMT NUMBER(11,2);
v_op_amt NUMBER(11,2);
v_ctg_codes varchar2(500);
V_EXE_QUERY VARCHAR2(1000);
BEGIN

        
   /*   IF (P_CTGRY_CD = 'ADMIN' OR P_CTGRY_CD = 'TRACTOR'  OR P_CTGRY_CD = 'TRAILER' OR P_CTGRY_CD = 'BACKHAUL' ) AND P_CALC_VLDN = 'C'  THEN
    
           V_EXE_QUERY := 'SELECT SUM(DTL_AMT)   FROM CARR_INV_DTL WHERE INV_ID = ' || P_INV_ID  || ' AND   DTL_AMT >0 AND INV_CTGY_CD IN ' ;
    ELSIF  (P_CTGRY_CD = 'FUEL' OR P_CTGRY_CD = 'MILEAGE') AND P_CALC_VLDN = 'C' THEN
     
      V_EXE_QUERY := 'SELECT AVG(UNIT_PRICE_AMT)   FROM CARR_INV_DTL WHERE INV_ID =  ' || P_INV_ID  || '  P_INV_ID AND  DTL_AMT >0  AND INV_CTGY_CD IN ';
      
      ELSIF (P_CTGRY_CD = 'ADMIN' OR P_CTGRY_CD = 'TRACTOR'  OR P_CTGRY_CD = 'TRAILER' OR P_CTGRY_CD = 'BACKHAUL' OR  P_CTGRY_CD = 'FUEL' OR P_CTGRY_CD = 'MILEAGE') AND P_CALC_VLDN = 'V' THEN
         V_EXE_QUERY := 'SELECT SUM(DTL_AMT)   FROM CARR_INV_DTL WHERE INV_ID =  ' || P_INV_ID  || '  AND   DTL_AMT >0 AND INV_CTGY_CD IN ' ;
    END IF;
    
       IF P_CTGRY_CD = 'ADMIN' THEN
      v_ctg_codes := ' (''DRVRCHG'',''FRTADJMNT'',''GENEXP'',''GEN_SPOTTING'',''LABOR'',''LABOR-DUMP/REPK'',''MISC-CHARGES'',''OVERTIME-LABOR'', ''SGLTRDRV'',''SLPTRDRV'',''STOPOFF-CHG'',''TOLLCHG'',''THRDPRTYTX'',''DROPLOT'',''OTHERCR'',''UNKNOWN'') ';
      elsif P_CTGRY_CD = 'FUEL' THEN
       v_ctg_codes := '  (''FUELSURCHG'',''FUEL_TAX'') ';
      elsif P_CTGRY_CD = 'MILEAGE' THEN
       v_ctg_codes :=   '  (''VARBLMLG'') ' ;
      elsif P_CTGRY_CD = 'TRACTOR' THEN
       v_ctg_codes :=  '  (''CHGDAYCAB'',''SLIPTRCT'',''SLPRCBCHR'',''SGLTRCTOR'') ' ;
      elsif P_CTGRY_CD = 'TRAILER' THEN
       v_ctg_codes :=      ' (''DRYVANTR'',''LEASED-TRLR-CHG'',''PLATETRL53'',''REFRTR53'',''ROLLERBEDTRL'') ' ;
           ELSIF P_CTGRY_CD = 'BACKHAUL' THEN
           v_ctg_codes := '(  ''BACKHAULCR'', ''BALER'', ''BHFUELCR'', ''INBOUNDMATCR'' ) ';
      END IF;

V_EXE_QUERY := V_EXE_QUERY || v_ctg_codes;

EXECUTE IMMEDIATE V_EXE_QUERY INTO V_DTL_AMT;
      dbms_output.put_line(V_DTL_AMT || ' V_EXE_QUERY:  ' || V_EXE_QUERY); 
      */

   IF P_CTGRY_CD = 'ADMIN' THEN
      dbms_output.put_line('inside admin');
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id
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
'THRDPRTYTX',
'DROPLOT',
'OTHERCR',
'UNKNOWN'
) ;
    
END IF;
  
  IF P_CTGRY_CD = 'FUEL'   THEN
      IF  P_CALC_VLDN = 'C' THEN
      SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE inV_ID = p_inv_id   
      AND INV_CTGY_CD IN
       ('FUELSURCHG',
'FUEL_TAX') ;
    ELSIF P_CALC_VLDN = 'V' THEN
    
     SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id
      AND INV_CTGY_CD IN
     ( 'FUELSURCHG',
'FUEL_TAX') ;
END IF;
END IF;
  

  IF P_CTGRY_CD = 'MILEAGE' THEN
           
   IF  P_CALC_VLDN = 'C' THEN

      SELECT AVG(UNIT_PRICE_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id    
      AND INV_CTGY_CD IN
       ('VARBLMLG') ;
     ELSIF P_CALC_VLDN = 'V' THEN
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id
      AND INV_CTGY_CD IN
     ( 'VARBLMLG') ;
     END IF;
     
END IF;


 IF P_CTGRY_CD = 'BACKHAUL' THEN
      
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id    
      AND INV_CTGY_CD IN
       ('BACKHAULCR',
'BALER',
'BHFUELCR',
'INBOUNDMATCR'
) ;
  
END IF;

 IF P_CTGRY_CD = 'TRACTOR' THEN
      
      SELECT SUM(dtl_amt) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID  = p_inv_id   
      AND INV_CTGY_CD IN
       ('CHGDAYCAB',
'SLIPTRCT',
'SLPRCBCHR',
'SGLTRCTOR'
) ;
    

END IF;

  IF P_CTGRY_CD = 'TRAILER' THEN
      
      SELECT SUM(dtl_amt)  INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = p_inv_id  
      AND INV_CTGY_CD IN
       ('DRYVANTR',
'LEASED-TRLR-CHG',
'PLATETRL53',
'REFRTR53',
'ROLLERBEDTRL'
) ;
    
END IF; 

IF P_CTGRY_CD = 'CNG' THEN
         dbms_output.put_line('insidecng');
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
             WHERE INV_ID = P_inv_id
             AND DTL_AMT > 0  
          AND INV_CTGY_CD IN
       ('CNG_CONV_FCTR',
'CNG_FIXED_COMP',
'CNG_FIXED_ELEC',
'CNG_FIXED_MAINT',
'CNG_FIXED_MGT',
'CNG_FIXED_RE',
'CNG_INDEX_PRICE',
'GGE_PURCHASED',
'FUELSURCHG'
) ;
    

END IF;

 IF P_CTGRY_CD = 'LEASE' THEN
   dbms_output.put_line('insidecleaseng');
      IF  P_DISTR_BUS = 51 THEN
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID  
       AND DTL_AMT >0
      AND INV_CTGY_CD NOT  IN
       ('CNG MLG') ;
ELSE
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID
       AND DTL_AMT > 0  
      AND INV_CTGY_CD  IN
       ('CNGTRCTOR' ) ;
       END IF;
END IF;    


 IF P_CTGRY_CD = 'MAINT'   THEN
   dbms_output.put_line('insidecngmaint');
      IF p_distr_bus = 51 THEN
      SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID
       AND DTL_AMT >0
      AND INV_CTGY_CD IN
       ('CNG MLG') ;
       
       ELSE
            SELECT SUM(DTL_AMT) INTO V_DTL_AMT FROM CARR_INV_DTL 
       WHERE INV_ID = P_INV_ID
       AND DTL_AMT >0;    
END IF;
end if;

v_op_amt := v_dtl_amt;
   RETURN V_OP_AMT;
   EXCEPTION
     WHEN OTHERS THEN
     dbms_output.put_line('INSIDE FUNCTION : ' || SQLERRM);
       V_OP_AMT := NULL;
       -- Consider logging the error and then re-raise
      -- RAISE;
END FN_MULE_GET_INV_UP;
/
