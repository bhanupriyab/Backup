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
