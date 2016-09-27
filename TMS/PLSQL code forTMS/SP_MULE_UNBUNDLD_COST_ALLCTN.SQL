create or replace
PROCEDURE     SP_MULE_UNBUNDLD_COST_ALLCTN(status out number , err_msg out varchar2) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       SP_MULE_UNBUNDLD_COST_ALLCTN
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        9/12/2016   z919520       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_MULE_UNBUNDLD_COST_ALLCTN
      Sysdate:         9/12/2016
      Date and Time:   9/12/2016, 3:36:44 PM, and 9/12/2016 3:36:44 PM
      Username:        z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/

cursor carr_invoices_unbundld IS
SELECT DISTINCT  A.* FROM CARR_INV A , TEMP_CARR_INV_TYPE B
WHERE
A.CARR_BUS_ENTY_ID = B.CARR_BUS_ENTY_ID
AND B.INV_TYPE = 'UNBUNDLED'
AND A.CURR_STATUS_CD = 'APPROVED'
AND A.carr_BUS_ENTY_ID = 3682;

v_cnt_inv number;
v_valid_inv varchar2(10);
V_CNT_SHIP_IDS NUMBER;
V_FUEL_SURCHARGE_UP NUMBER(11,4);
V_GEN_EXP_UP NUMBER(11,4);
V_MILEAGE_UP NUMBER(11,4);
V_BACKHL_AMT NUMBER(11,4);
V_CNT_TRCT_DAYS NUMBER;
v_cnt_shpmt_in_day number;
v_tot_miles_in_day number;
v_tractor_up number(11,4);
V_TRCTR_COST_PER_DAY number(11,4);
V_TRCTR_COST_PER_DAY_CNT number(11,4);
v_trct_line_cost number(11,4);
v_dis_trct_cnt number;
v_trailer_up number(11,4);
V_TRAILER_COST_PER_DAY number(11,4);
V_TRAILER_COST_PER_DAY_CNT number(11,4);
v_tral_line_cost number(11,4);
v_dis_tral_cnt number;
l_text varchar2(100) := null;
V_CNG_AMT number(11,4);
V_LEASE_AMT number(11,4);
V_MAINT_AMT number(11,4);

BEGIN
 
dbms_output.put_line('INSIDE BEGIN');

fOR C_INV_REC IN carr_invoices_unbundld
LOOP
dbms_output.put_line('INSIDE MAIN LOOP');
l_text := null;
if C_INV_REC.distr_pnt_bus_enty_id = 51 then
dbms_output.put_line('INSIDE IF 51');
select count(distinct carr_BUS_ENTY_ID) into v_cnt_inv from CARR_INV where 
 distr_pnt_bus_enty_id = C_INV_REC.distr_pnt_bus_enty_id
and bill_period_start_dt = C_INV_REC.bill_period_start_dt
and carr_BUS_ENTY_ID in (3682, 6555, 6556);
end if;

if C_INV_REC.distr_pnt_bus_enty_id = 46 then
dbms_output.put_line('INSIDE IF 46');
select count(distinct carr_BUS_ENTY_ID) into v_cnt_inv from CARR_INV where 
distr_pnt_bus_enty_id = C_INV_REC.distr_pnt_bus_enty_id
and bill_period_start_dt = C_INV_REC.bill_period_start_dt
and carr_BUS_ENTY_ID in (3682, 6752, 6751, 6756);
end if;

dbms_output.put_line('v_cnt_inv:  ' || v_cnt_inv);
if ( C_INV_REC.distr_pnt_bus_enty_id = 51 and v_cnt_inv =3)
then
dbms_output.put_line('INSIDE IF  51 CNT');
v_valid_inv := 'Y';
ELSIF  (C_INV_REC.distr_pnt_bus_enty_id = 46 and v_cnt_inv =4)
THEN
dbms_output.put_line('INSIDE IF 46 CNT');
v_valid_inv := 'Y';
ELSE
dbms_output.put_line('INSIDE ELSE 51');
v_valid_inv := 'N';
END IF;
  
if v_valid_inv = 'Y' THEN
dbms_output.put_line('INSIDE IF  51 VALID');
FOR cur_rec IN (select inv_id from CARR_INV where 
distr_pnt_bus_enty_id = C_INV_REC.distr_pnt_bus_enty_id
and bill_period_start_dt = C_INV_REC.bill_period_start_dt)
 LOOP
    l_text := l_text || ',' || cur_rec.inv_id;
  END LOOP;
 l_text :=  LTRIM(l_text, ',');
 dbms_output.put_line('LTEXT:' || L_TEXT);
begin
 Select count( DISTINCT nvl(TO_CHAR(AB_SHPMT_ID),BOL_NBR))   INTO V_CNT_SHIP_IDS from CARR_INV_SHPMT_DTL where inv_id = C_INV_REC.inv_id
  and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0;  
end;

V_GEN_EXP_UP := FN_MULE_GET_INV_UP(l_text, 'ADMIN');
V_GEN_EXP_UP := V_GEN_EXP_UP/V_CNT_SHIP_IDS;

dbms_output.put_line('admin: ' ||V_GEN_EXP_UP);

V_FUEL_SURCHARGE_UP := FN_MULE_GET_INV_UP(l_text, 'FUEL');
dbms_output.put_line('fuel: ' ||V_FUEL_SURCHARGE_UP);

V_MILEAGE_UP := FN_MULE_GET_INV_UP(l_text, 'MILEAGE');
dbms_output.put_line('MILEAGE: ' ||V_MILEAGE_UP);

V_BACKHL_AMT := FN_MULE_GET_INV_UP(l_text, 'BACKHAUL');
V_BACKHL_AMT := V_BACKHL_AMT/V_CNT_SHIP_IDS;

V_TRACTOR_UP := FN_MULE_GET_INV_UP(l_text, 'TRACTOR');
v_trailer_up := FN_MULE_GET_INV_UP(l_text, 'TRAILER');
dbms_output.put_line('V_TRACTOR_UP: ' ||V_TRACTOR_UP);

V_CNG_AMT := FN_MULE_GET_INV_UP(l_text, 'CNG');
V_CNG_AMT := V_CNG_AMT/V_CNT_SHIP_IDS;

V_LEASE_AMT := FN_MULE_GET_INV_UP(l_text, 'LEASE');
V_LEASE_AMT:= V_LEASE_AMT/V_CNT_SHIP_IDS;

V_MAINT_AMT := FN_MULE_GET_INV_UP(l_text, 'MAINT');
V_MAINT_AMT := V_MAINT_AMT/V_CNT_SHIP_IDS;

FOR C_REC_SHPMTS IN (SELECT nvl(to_char(AB_SHPMT_ID),bol_nbr) as ab_shpmt_id , SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) TOT_MILES FROM CARR_INV_SHPMT_DTL
WHERE INV_ID = C_INV_REC.INV_ID and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0 group by nvl(to_char(AB_SHPMT_ID),bol_nbr) order by  AB_SHPMT_ID)
LOOP
  
insert into TEMP_CARR_MULE_COST_ALLOC_DTLS
(
INV_ID,
CATGY, 
AB_SHIP_ID, 
ADMIN_COST, 
FUEL_COST, 
MILGE_COST,
BCKHAUL_COST,
CNG_COST,
LEASE_COST,
MAINT_COST
 )
VALUES
(
C_INV_REC.inv_id,
'UNBUNDLED',
C_REC_SHPMTS.AB_SHPMT_ID,
V_GEN_EXP_UP,
V_FUEL_SURCHARGE_UP*C_REC_SHPMTS.TOT_MILES,
V_MILEAGE_UP*C_REC_SHPMTS.TOT_MILES,
V_BACKHL_AMT,
V_CNG_AMT,
V_LEASE_AMT,
V_MAINT_AMT
);
dbms_output.put_line('shp id :' || C_REC_SHPMTS.AB_SHPMT_ID  );

END LOOP;

END IF;

END LOOP;
err_msg := sqlerrm;
      status := 1;
      dbms_output.put_line('OP: ' || ERR_MSG);
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
             dbms_output.put_line('ERR : ' || sqlerrm);
      err_msg := sqlerrm;
      status := 0;
END SP_MULE_UNBUNDLD_COST_ALLCTN;