CREATE OR REPLACE PROCEDURE SCD.SP_MULE_COST_ALLOCATION(status out number , err_msg out varchar2) IS
/******************************************************************************
   NAME:       SP_MULE_COST_ALLOCATION
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        8/18/2016   Z919520       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_MULE_COST_ALLOCATION
      Sysdate:         8/18/2016
      Date and Time:   8/18/2016, 11:28:18 AM, and 8/18/2016 11:28:18 AM
      Username:        Z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
CURSOR CARR_INVOICES_DEDCTD IS
SELECT DISTINCT  A.* FROM CARR_INV A , TEMP_CARR_INV_TYPE B
WHERE
A.CARR_BUS_ENTY_ID = B.CARR_BUS_ENTY_ID
AND B.INV_TYPE = 'DEDICATED'
AND A.CURR_STATUS_CD = 'APPROVED';

CURSOR CARR_INV_DTLS(I_INV_ID NUMBER) IS
SELECT * FROM CARR_INV_DTL 
WHERE INV_ID = I_INV_ID;

CURSOR CARR_SHPMT_DTLS(I_INV_ID NUMBER) IS
SELECT nvl(AB_SHPMT_ID,bol_nbr) as ab_shpmt_id , SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) TOT_MILES FROM CARR_INV_SHPMT_DTL
WHERE INV_ID = I_INV_ID GROUP BY nvl(AB_SHPMT_ID,bol_nbr) order by  AB_SHPMT_ID;

cursor carr_shpmt_tractr_dtls(i_inv_id number ) is
 select inv_id, tractor_nbr, pickup_dt, shpmt_type_cd, ab_shpmt_id, bol_nbr,(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) tot_line_miles from 
CARR_INV_SHPMT_DTL where inv_id = I_INV_ID;

--select TRACTOR_NBR,PICKUP_DT,shpmt_type_cd, (LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) tot_line_miles from CARR_INV_SHPMT_DTL where inv_id = I_INV_ID
-- order by TRACTOR_NBR, PICKUP_DT;
--SELECT TRACTOR_NBR,  PICKUP_DT, NVL(AB_SHPMT_ID,BOL_NBR) AS ab_shpmt_id, SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) tot_shp_miles FROM CARR_INV_SHPMT_DTL 
--WHERE INV_ID = I_INV_ID GROUP BY  TRACTOR_NBR, PICKUP_DT,  NVL(AB_SHPMT_ID,BOL_NBR)  ORDER BY TRACTOR_NBR,  PICKUP_DT,  NVL(AB_SHPMT_ID,BOL_NBR);

--SELECT TRACTOR_NBR,  PICKUP_DT,count(ab_shpmt_id) , SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY) total_miles FROM CARR_INV_SHPMT_DTL 
--WHERE INV_ID = 27676 AND AB_SHPMT_ID is not null GROUP BY  TRACTOR_NBR, PICKUP_DT;
--V_INV_DTLS_REC CARR_INV_DTL%ROWTYPE;
--V_SHPMT_DTLS_REC CARR_INV_SHPMT_DTL%ROWTYPE;
V_FUEL_SURCHARGE_UP NUMBER(11,4);
V_GEN_EXP_UP NUMBER(11,4);
V_MILEAGE_UP NUMBER(11,4);
V_BACKHL_AMT NUMBER(11,4);
V_CNT_SHIP_IDS NUMBER;
V_CNT_TRCT_DAYS NUMBER;
v_cnt_shpmt_in_day number;
v_tot_miles_in_day number;
v_tractor_up number(11,4);
V_TRCTR_COST_PER_DAY number(11,4);
V_TRCTR_COST_PER_DAY_CNT number(11,4);
v_trct_line_cost number(11,4);
v_dis_trct_cnt number;
--TYPE T_INV_DTLS IS TABLE OF CARR_INV_DTL%ROWTYPE;
--TYPE T_SHPMT_DTLS_REC IS TABLE OF CARR_INV_SHPMT_DTL%ROWTYPE;
--TYPE T_SHIP_IDS  is table of VARCHAR2(10);
--V_SHIP_IDS T_SHIP_IDS;


BEGIN

   
   FOR C_REC_INV IN CARR_INVOICES_DEDCTD LOOP
   V_MILEAGE_UP := NULL;
   V_GEN_EXP_UP := NULL;
   V_FUEL_SURCHARGE_UP := NULL;
  
begin
 Select count(distinct AB_SHPMT_ID) INTO V_CNT_SHIP_IDS from CARR_INV_SHPMT_DTL where inv_id = c_rec_inv.inv_id AND AB_SHPMT_ID IS NOT NULL; 
end;

--BEGIN 
--SELECT COUNT(DISTINCT PICKUP_DT) INTO  V_CNT_TRCT_DAYS FROM CARR_INV_SHPMT_DTL WHERE inv_id = c_rec_inv.inv_id;
--END;


V_GEN_EXP_UP := FN_MULE_GET_INV_UP(c_rec_inv.inv_id, 'ADMIN');
V_GEN_EXP_UP := V_GEN_EXP_UP/V_CNT_SHIP_IDS;

dbms_output.put_line('admin: ' ||V_GEN_EXP_UP);

V_MILEAGE_UP := FN_MULE_GET_INV_UP(c_rec_inv.inv_id, 'MILEAGE');
dbms_output.put_line('mileage: ' ||V_MILEAGE_UP);
V_FUEL_SURCHARGE_UP := FN_MULE_GET_INV_UP(c_rec_inv.inv_id, 'FUEL');
dbms_output.put_line('fuel: ' ||V_FUEL_SURCHARGE_UP);
V_BACKHL_AMT := FN_MULE_GET_INV_UP(c_rec_inv.inv_id, 'FUEL');
V_TRACTOR_UP := FN_MULE_GET_INV_UP(c_rec_inv.inv_id, 'TRACTOR');
dbms_output.put_line('V_TRACTOR_UP: ' ||V_TRACTOR_UP);



for c_shpmt_rec in CARR_SHPMT_DTLS(c_rec_inv.inv_id)
loop
--dbms_output.put_line('inside shmpt records');

insert into TEMP_CARR_MULE_COST_ALLOC_DTLS
(
INV_ID,
CATGY, 
AB_SHIP_ID, 
ADMIN_COST, 
FUEL_COST, 
MILGE_COST
 )
VALUES
(
c_rec_inv.inv_id,
'DEDICATED',
c_shpmt_rec.AB_SHPMT_ID,
V_GEN_EXP_UP,
V_FUEL_SURCHARGE_UP*c_shpmt_rec.TOT_MILES,
V_MILEAGE_UP*c_shpmt_rec.TOT_MILES
);
--dbms_output.put_line('shp id :' || c_shpmt_rec.AB_SHPMT_ID  );
end loop;

COMMIT;

begin
 SELECT SUM(CNT) into v_dis_trct_cnt FROM (SELECT TRACTOR_NBR, COUNT(DISTINCT PICKUP_DT) CNT FROM ( SELECT INV_ID, TRACTOR_NBR, PICKUP_DT , SHPMT_TYPE_CD , (LOADED_MILES_QTY+EMPTY_MILES_QTY+DEADHEAD_MILES_QTY)  TOTAL_MILES FROM CARR_INV_SHPMT_DTL  WHERE INV_ID=27681
 ORDER BY INV_ID, TRACTOR_NBR, PICKUP_DT) GROUP BY TRACTOR_NBR);
end ;

V_TRCTR_COST_PER_DAY := V_TRACTOR_UP/v_dis_trct_cnt;
dbms_output.put_line('V_TRCTR_COST_PER_DAY: ' ||V_TRCTR_COST_PER_DAY);

execute immediate 'truncate table temp_shmpt_dtl';


for trct_rec in carr_shpmt_tractr_dtls(c_rec_inv.inv_id)
loop
begin
dbms_output.put_line('inside TRACTOR shmpt records : TRC_NBR : ' || trct_rec.tractor_nbr  || ' -- ' ||  trct_rec.PICKUP_DT);
select sum(LOADED_MILES_QTY+DEADHEAD_MILES_QTY+EMPTY_MILES_QTY) into v_tot_miles_in_day from carr_inv_shpmt_dtl where inv_id = c_rec_inv.inv_id 
and tractor_nbr = trct_rec.tractor_nbr
  and pickup_dt = trct_rec.PICKUP_DT;
end;
if v_tot_miles_in_day = 0 then
v_trct_line_cost := 0;
else
v_trct_line_cost := (trct_rec.tot_line_miles/v_tot_miles_in_day)*V_TRCTR_COST_PER_DAY;
end if;
dbms_output.put_line('v_trct_line_cost: ' ||v_trct_line_cost);
begin
insert into temp_shmpt_dtl values ( trct_rec.inv_id, trct_rec.tractor_nbr,  trct_rec.pickup_dt,  trct_rec.shpmt_type_cd,  trct_rec.ab_shpmt_id, trct_rec.bol_nbr, trct_rec.tot_line_miles,v_trct_line_cost );


--update  temp_shmpt_dtl a  set a.line_trct_cost = v_trct_line_cost where 
--inv_id = trct_rec.inv_id
--and tractor_nbr = trct_rec.tractor_nbr
--and pickup_dt = trct_rec.pickup_dt
--and shpmt_type_cd = trct_rec.shpmt_type_cd
--and ab_shpmt_id = trct_rec.ab_shpmt_id
--and bol_nbr = trct_rec.bol_nbr
--and tot_line_miles= trct_rec.tot_line_miles;
exception
WHEN OTHERS THEN
      dbms_output.put_line('error: '||sqlerrm);
end;
commit;
dbms_output.put_line('after updating line cost: ' ||v_trct_line_cost);

/*
dbms_output.put_line('inside TRACTOR shmpt records : TRC_NBR : ' || trct_rec.tractor_nbr  || ' -- ' ||  trct_rec.PICKUP_DT);
begin
select count(DISTINCT ab_shpmt_id) , SUM(LOADED_MILES_QTY+DEADHEAD_MILES_QTY) total_miles into v_cnt_shpmt_in_day , v_tot_miles_in_day FROM CARR_INV_SHPMT_DTL 
WHERE INV_ID = c_rec_inv.inv_id AND AB_SHPMT_ID is not null
and tractor_nbr =  trct_rec.tractor_nbr
and pickup_dt = trct_rec.PICKUP_DT;
end;
dbms_output.put_line( 'v_cnt_shpmt_in_day : ' ||  v_cnt_shpmt_in_day || 'v_tot_miles_in_day :  ' || v_tot_miles_in_day);
if V_CNT_SHPMT_IN_DAY = 1 THEN
UPDATE TEMP_CARR_MULE_COST_ALLOC_DTLS SET TRCTR_COST = NVL(TRCTR_COST,0)+V_TRCTR_COST_PER_DAY
WHERE INV_ID = c_rec_inv.inv_id 
AND AB_SHiP_ID = trct_rec.ab_shpmt_id;
dbms_output.put_line('INSIDE COUNT 1 : ' ||  V_TRCTR_COST_PER_DAY);
ELSIF V_CNT_SHPMT_IN_DAY > 1 THEN
IF v_tot_miles_in_day = 0 THEN
V_TRCTR_COST_PER_DAY_CNT := 0;
ELSE
V_TRCTR_COST_PER_DAY_CNT := (trct_rec.tot_shp_miles/v_tot_miles_in_day)*V_TRCTR_COST_PER_DAY;
END IF;
dbms_output.put_line('INSIDE COUNT > 1  : ' ||  V_TRCTR_COST_PER_DAY_CNT);
UPDATE TEMP_CARR_MULE_COST_ALLOC_DTLS SET TRCTR_COST = NVL(TRCTR_COST,0)+V_TRCTR_COST_PER_DAY_CNT
WHERE INV_ID = c_rec_inv.inv_id 
AND AB_SHiP_ID = trct_rec.ab_shpmt_id;

END IF;
COMMIT;*/


end loop;



 END LOOP;
 status := 1;
   err_msg := sqlerrm;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        err_msg := sqlerrm;
      status := 0;
     WHEN OTHERS THEN
      dbms_output.put_line('error: '||sqlerrm);
    --  err_no := sqlerrm;
      err_msg := sqlerrm;
      status := 0;
END SP_MULE_COST_ALLOCATION;
/
