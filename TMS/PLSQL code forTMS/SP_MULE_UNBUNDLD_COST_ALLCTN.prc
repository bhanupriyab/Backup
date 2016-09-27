DROP PROCEDURE SCD.SP_MULE_UNBUNDLD_COST_ALLCTN;

CREATE OR REPLACE PROCEDURE SCD.SP_MULE_UNBUNDLD_COST_ALLCTN(status_cd  out number , status_msg out varchar2) IS
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
AND B.REF_COST = 'PRIMARY';

v_cnt_inv number;
v_cnt_inv_ref number;
v_valid_inv varchar2(10);
V_CNT_SHIP_IDS NUMBER;
V_FUEL_SURCHARGE_UP NUMBER(36,14);
V_GEN_EXP_UP NUMBER(36,14);
V_MILEAGE_UP  NUMBER(36,14);
V_BACKHL_AMT  NUMBER(36,14);
V_CNT_TRCT_DAYS NUMBER;
v_cnt_shpmt_in_day number;
v_tot_miles_in_day number;
v_tractor_up NUMBER(36,14);
V_TRCTR_COST_PER_DAY  NUMBER(36,14);
V_TRCTR_COST_PER_DAY_CNT  NUMBER(36,14);
v_trct_line_cost  NUMBER(36,14);
v_dis_trct_cnt number;
v_trailer_up  NUMBER(36,14);
V_TRAILER_COST_PER_DAY  NUMBER(36,14);
V_TRAILER_COST_PER_DAY_CNT  NUMBER(36,14);
v_tral_line_cost  NUMBER(36,14);
v_dis_tral_cnt number;
--l_text varchar2(100) := null;
V_CNG_AMT  NUMBER(36,14);
V_LEASE_AMT  NUMBER(36,14);
v_lease_per_day  NUMBER(36,14);
v_lease_line_cost   NUMBER(36,14);
V_MAINT_AMT  NUMBER(36,14);
V_INV_ID NUMBER(9);
V_VALID_INV_FLAG NUMBER;
BEGIN
 
dbms_output.put_line('INSIDE BEGIN');

fOR C_INV_REC IN carr_invoices_unbundld
LOOP
dbms_output.put_line('INSIDE MAIN LOOP');


BEGIN
select count(distinct carr_BUS_ENTY_ID) into v_cnt_inv from CARR_INV a where 
 distr_pnt_bus_enty_id = C_INV_REC.distr_pnt_bus_enty_id
and bill_period_start_dt = C_INV_REC.bill_period_start_dt
and carr_BUS_ENTY_ID in (select distinct carr_BUS_ENTY_ID from temp_carr_inv_type b
where a.distr_pnt_bus_enty_id = b.distr_pnt_bus_enty_id);
END;

BEGIN
select count(distinct carr_BUS_ENTY_ID) into v_cnt_inv_REF from temp_carr_inv_type where 
distr_pnt_bus_enty_id = C_INV_REC.distr_pnt_bus_enty_id;
END;

dbms_output.put_line('v_cnt_inv:  ' || v_cnt_inv || 'v_cnt_inv_REF: ' || v_cnt_inv_REF );

IF ( v_cnt_inv = v_cnt_inv_ref )
then
dbms_output.put_line('INSIDE cnt equal');
v_valid_inv := 'Y';
ELSE
dbms_output.put_line('INSIDE ELSE cnt');
v_valid_inv := 'N';
END IF;
  
dbms_output.put_line('v_valid_inv: ' || C_INV_REC.INV_ID || '-' || v_valid_inv);

if v_valid_inv = 'Y' THEN
dbms_output.put_line('INSIDE IF  VALID');

begin
 Select count( DISTINCT nvl(TO_CHAR(AB_SHPMT_ID),BOL_NBR))   INTO V_CNT_SHIP_IDS from CARR_INV_SHPMT_DTL where inv_id = C_INV_REC.inv_id
  and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0;  
end;

V_GEN_EXP_UP := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'ADMIN', '' , 'C');
V_GEN_EXP_UP := V_GEN_EXP_UP/V_CNT_SHIP_IDS;

--dbms_output.put_line('admin: ' ||V_GEN_EXP_UP);

V_FUEL_SURCHARGE_UP := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'FUEL', '' , 'C');
--dbms_output.put_line('fuel: ' ||V_FUEL_SURCHARGE_UP);

V_MILEAGE_UP := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'MILEAGE', '' , 'C');
--dbms_output.put_line('MILEAGE: ' ||V_MILEAGE_UP);

V_BACKHL_AMT := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'BACKHAUL', '' , 'C');
V_BACKHL_AMT := V_BACKHL_AMT/V_CNT_SHIP_IDS;

V_TRACTOR_UP := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'TRACTOR', '', 'C');
v_trailer_up := FN_MULE_GET_INV_UP(C_INV_REC.inv_id, 'TRAILER', '' , 'C');
--dbms_output.put_line('V_TRACTOR_UP: ' ||V_TRACTOR_UP);

V_INV_ID := FN_GET_UNBUNDLD_INV(C_INV_REC.distr_pnt_bus_enty_id, C_INV_REC.BILL_PERIOD_START_DT, 'CNG' );
V_CNG_AMT := FN_MULE_GET_INV_UP(V_INV_ID, 'CNG', C_INV_REC.distr_pnt_bus_enty_id,  'C');
V_CNG_AMT := V_CNG_AMT/V_CNT_SHIP_IDS;

V_INV_ID := FN_GET_UNBUNDLD_INV(C_INV_REC.distr_pnt_bus_enty_id, C_INV_REC.BILL_PERIOD_START_DT, 'LEASE');
V_LEASE_AMT := FN_MULE_GET_INV_UP(V_INV_ID, 'LEASE', C_INV_REC.distr_pnt_bus_enty_id, 'C');
--V_LEASE_AMT:= V_LEASE_AMT/V_CNT_SHIP_IDS;

V_INV_ID := FN_GET_UNBUNDLD_INV(C_INV_REC.distr_pnt_bus_enty_id, C_INV_REC.BILL_PERIOD_START_DT, 'MAINT');
V_MAINT_AMT := FN_MULE_GET_INV_UP(V_INV_ID, 'MAINT', C_INV_REC.distr_pnt_bus_enty_iD , 'C');
V_MAINT_AMT := V_MAINT_AMT/V_CNT_SHIP_IDS;

dbms_output.put_line('V_CNT_SHIP_IDS: '|| V_CNT_SHIP_IDS  || 'admin: ' ||V_GEN_EXP_UP || ' mileage: ' ||V_MILEAGE_UP || ' fuel: ' ||V_FUEL_SURCHARGE_UP || ' V_TRACTOR_UP: ' ||V_TRACTOR_UP || ' lease amt: ' || v_lease_amt);

FOR C_REC_SHPMTS IN (SELECT nvl(to_char(AB_SHPMT_ID),bol_nbr) as ab_shpmt_id , SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) TOT_MILES FROM CARR_INV_SHPMT_DTL
WHERE INV_ID = C_INV_REC.INV_ID and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0 group by nvl(to_char(AB_SHPMT_ID),bol_nbr) order by  AB_SHPMT_ID)
LOOP
  
insert into TEMP_CARR_MULE_COST_ALLOC_DTLS
(
INV_ID,
CATGY, 
SHPM_NUM, 
ADMIN_COST, 
FUEL_COST, 
MILGE_COST,
BCKHAUL_COST,
cng_cost,
maint_cost
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
v_cng_amt,
v_maint_amt
);
--dbms_output.put_line('shp id :' || C_REC_SHPMTS.AB_SHPMT_ID  );

END LOOP;

-- Tractor Cost and lease cost

begin
 SELECT SUM(CNT) into v_dis_trct_cnt FROM (SELECT TRACTOR_NBR, COUNT(DISTINCT PICKUP_DT) CNT FROM ( SELECT INV_ID, TRACTOR_NBR, PICKUP_DT , SHPMT_TYPE_CD , (LOADED_MILES_QTY+EMPTY_MILES_QTY+DEADHEAD_MILES_QTY)  TOTAL_MILES
  FROM CARR_INV_SHPMT_DTL  WHERE INV_ID = C_INV_REC.inv_id  ORDER BY INV_ID, TRACTOR_NBR, PICKUP_DT) GROUP BY TRACTOR_NBR);
end ;

V_TRCTR_COST_PER_DAY := V_TRACTOR_UP/v_dis_trct_cnt;
v_lease_per_day := v_lease_amt/v_dis_trct_cnt;
dbms_output.put_line('V_TRCTR_COST_PER_DAY: ' ||V_TRCTR_COST_PER_DAY || ' lease : ' || v_lease_per_day );

execute immediate 'truncate table temp_shmpt_dtl';

for c_trct_rec in ( select inv_id, tractor_nbr, pickup_dt, shpmt_type_cd, ab_shpmt_id, bol_nbr, decode ( (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) , 0 , 1 , (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) ) tot_line_miles from 
CARR_INV_SHPMT_DTL where inv_id = C_INV_REC.inv_id and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0)
loop
begin
--dbms_output.put_line('inside TRACTOR shmpt records : TRC_NBR : ' || trct_rec.tractor_nbr  || ' -- ' ||  trct_rec.PICKUP_DT);
/*Get the tractor days at invoice level and then split the cost per day on shipments on that day based on miles*/
select sum(decode ( (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) , 0 , 1 , (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) ) ) into v_tot_miles_in_day from carr_inv_shpmt_dtl where inv_id = c_inv_rec.inv_id 
and tractor_nbr = c_trct_rec.tractor_nbr
  and pickup_dt = c_trct_rec.PICKUP_DT;
end;

v_trct_line_cost := (c_trct_rec.tot_line_miles/v_tot_miles_in_day)*V_TRCTR_COST_PER_DAY;
v_lease_line_cost := (c_trct_rec.tot_line_miles/v_tot_miles_in_day)*v_lease_per_day;
--dbms_output.put_line('inside TRACTOR shmpt records : TRC_NBR : ' || trct_rec.tractor_nbr  || ' -- ' ||  trct_rec.PICKUP_DT  || 'v_trct_line_cost: ' ||v_trct_line_cost  || '-' ||trct_rec.tot_line_miles  || '-'|| v_tot_miles_in_day  );

begin
insert into temp_shmpt_dtl values ( c_trct_rec.inv_id, c_trct_rec.tractor_nbr,  c_trct_rec.pickup_dt,  c_trct_rec.shpmt_type_cd,  c_trct_rec.ab_shpmt_id, c_trct_rec.bol_nbr, c_trct_rec.tot_line_miles,v_trct_line_cost, v_lease_line_cost );
exception
WHEN OTHERS THEN
      dbms_output.put_line('error: '||sqlerrm);
end;
commit;
end loop;

--Trailer Cost

begin
 SELECT SUM(CNT) into v_dis_tral_cnt FROM (SELECT TRAILER_NBR, COUNT(DISTINCT PICKUP_DT) CNT FROM ( SELECT INV_ID, TRAILER_NBR, PICKUP_DT , SHPMT_TYPE_CD , (LOADED_MILES_QTY+EMPTY_MILES_QTY+DEADHEAD_MILES_QTY)  TOTAL_MILES
  FROM CARR_INV_SHPMT_DTL  WHERE INV_ID=c_inv_rec.inv_id  ORDER BY INV_ID, TRAILER_NBR, PICKUP_DT) GROUP BY TRAILER_NBR);
end ;

V_TRAILER_COST_PER_DAY := V_TRAILER_UP/v_dis_tral_cnt;
dbms_output.put_line('V_TRAILER_COST_PER_DAY: ' ||V_TRAILER_COST_PER_DAY);

execute immediate 'truncate table temp_tral_shmpt_dtl';
/*For tractor cost allocation at line item level*/
for tral_rec in ( select inv_id, trailer_nbr, pickup_dt, shpmt_type_cd, ab_shpmt_id, bol_nbr, decode ( (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) , 0 , 1 , (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) ) tot_line_miles from 
CARR_INV_SHPMT_DTL where inv_id = c_inv_rec.inv_id and (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) > 0)
loop
begin
--dbms_output.put_line('inside TRAILER shmpt records : TRC_NBR : ' || tral_rec.trailer_nbr  || ' -- ' ||  tral_rec.PICKUP_DT);
/*Get the tractor days at invoice level and then split the cost per day on shipments on that day based on miles*/
select sum(decode ( (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) , 0 , 1 , (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) )) into v_tot_miles_in_day from carr_inv_shpmt_dtl where inv_id = c_inv_rec.inv_id 
and trailer_nbr = tral_rec.trailer_nbr
  and pickup_dt = tral_rec.PICKUP_DT;
end;
--dbms_output.put_line( v_tot_miles_in_day); 

v_trct_line_cost := (tral_rec.tot_line_miles/v_tot_miles_in_day)*V_trailer_COST_PER_DAY;

--dbms_output.put_line('inside triler shmpt records : TRC_NBR : ' || tral_rec.trailer_nbr  || ' -- ' ||  tral_rec.PICKUP_DT || '--' || 'v_tral_line_cost: ' ||v_tral_line_cost  || '-' ||tral_rec.tot_line_miles  || '-'|| v_tot_miles_in_day  );
begin
insert into temp_tral_shmpt_dtl values ( tral_rec.inv_id, tral_rec.trailer_nbr,  tral_rec.pickup_dt,  tral_rec.shpmt_type_cd,  tral_rec.ab_shpmt_id, tral_rec.bol_nbr, tral_rec.tot_line_miles,v_trct_line_cost );

exception
WHEN OTHERS THEN
      dbms_output.put_line('error: '||sqlerrm);
end;
commit;
end loop;

END IF;



V_VALID_INV_FLAG := FN_MULE_CHECK_VALID_INV( C_INV_REC.INV_ID, 'U');

BEGIN
UPDATE TEMP_CARR_MULE_COST_ALLOC_DTLS SET INV_ID_ST = DECODE(V_VALID_INV_FLAG, 1, 'Y', 0, 'N', 'N')
WHERE INV_ID = C_INV_REC.INV_ID;
--EXCEPTION
-- WHEN OTHERS THEN
-- ROLLBACK; 
END;
COMMIT;


END LOOP;
status_msg := sqlerrm;
      status_cd := 1;
      dbms_output.put_line('OP: ' || status_MSG);
   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
             dbms_output.put_line('ERR : ' || sqlerrm);
      status_msg := sqlerrm;
      status_cd := 0;
END SP_MULE_UNBUNDLD_COST_ALLCTN;
/
