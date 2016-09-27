DROP PROCEDURE SCD.SP_MULE_UPDATE_VCHR_STATUS;

CREATE OR REPLACE PROCEDURE SCD.SP_MULE_UPDATE_VCHR_STATUS(status_cd out number, status_msg out varchar2 ) IS

/******************************************************************************
   NAME:       SP_MULE_UPDATE_VCHR_STATUS
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        9/22/2016   Z919520       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_MULE_UPDATE_VCHR_STATUS
      Sysdate:         9/22/2016
      Date and Time:   9/22/2016, 3:44:47 PM, and 9/22/2016 3:44:47 PM
      Username:        Z919520 (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
cursor c_vhcr is
select inv_id, shpm_num, vchr_num, p_vchr_num , REGEXP_COUNT(Vchr_num, ',') VCHR_CNT , REGEXP_COUNT(P_vchr_num, ',')  P_VCHR_CNT
from TEMP_CARR_MULE_COST_ALLOC_DTLS
WHERE VCHR_STATUS IS NULL;

CURSOR C_DED_INV IS 
SELECT DISTINCT  A.* FROM CARR_INV A , TEMP_CARR_INV_TYPE B
WHERE
A.CARR_BUS_ENTY_ID = B.CARR_BUS_ENTY_ID
AND B.INV_TYPE = 'DEDICATED'
AND A.CURR_STATUS_CD = 'APPROVED';

cursor c_unb_inv is
SELECT DISTINCT  A.* FROM CARR_INV A , TEMP_CARR_INV_TYPE B
WHERE
A.CARR_BUS_ENTY_ID = B.CARR_BUS_ENTY_ID
AND B.INV_TYPE = 'UNBUNDLED'
AND A.CURR_STATUS_CD = 'APPROVED'
AND B.REF_COST = 'PRIMARY';

v_cnt_vchr number;
v_cnt_p_vchr number;
v_prcd_cnt number;
BEGIN

fOR C_REC IN C_VHCR
LOOP
IF C_REC.VCHR_CNT = C_REC.P_VCHR_CNT THEN
UPDATE TEMP_CARR_MULE_COST_ALLOC_DTLS SET VCHR_STATUS = 'P'
WHERE INV_ID = C_REC.inv_id
AND shpm_num = C_REC.shpm_num;
END IF;
END LOOP;


for c_ded_rec  in C_DED_INV
loop
begin
SELECT count(VCHR_NUM) INTO v_cnt_vchr FROM  TEMP_CARR_MULE_COST_ALLOC_DTLS WHERE 
INV_ID = c_ded_rec.INV_ID;

SELECT  count(VCHR_STATUS) INTO v_prcd_cnt FROM  TEMP_CARR_MULE_COST_ALLOC_DTLS WHERE 
INV_ID = c_ded_rec.INV_ID;
end;

IF v_cnt_vchr = v_prcd_cnt  AND v_cnt_vchr > 0 THEN

UPDATE CARR_INV SET CURR_STATUS_CD = 'SUBMITTED'
WHERE INV_ID = c_ded_rec.INV_ID
AND CURR_STATUS_CD = 'APPROVED'
AND BILL_PERIOD_START_DT = c_ded_rec.BILL_PERIOD_START_DT;

END IF;
end loop;


for c_UNB_rec  in C_UNB_INV
loop
begin
SELECT count(VCHR_NUM) INTO v_cnt_vchr FROM  TEMP_CARR_MULE_COST_ALLOC_DTLS WHERE 
INV_ID = c_UNB_rec.INV_ID;

SELECT  count(VCHR_STATUS) INTO v_prcd_cnt FROM  TEMP_CARR_MULE_COST_ALLOC_DTLS WHERE 
INV_ID = c_UNB_rec.INV_ID;
end;

IF v_cnt_vchr = v_prcd_cnt  AND v_cnt_vchr > 0 THEN

UPDATE CARR_INV  SET CURR_STATUS_CD = 'SUBMITTED'
WHERE CURR_STATUS_CD = 'APPROVED'
AND BILL_PERIOD_START_DT =  c_UNB_rec.BILL_PERIOD_START_DT
and DISTR_PNT_BUS_ENTY_ID = c_UNB_rec.DISTR_PNT_BUS_ENTY_ID;

END IF;
end loop;

status_msg := 1;
status_msg := SQLERRM;


   EXCEPTION
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       status_CD := 0;
       status_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('err_msg' || SQLERRM);
END SP_MULE_UPDATE_VCHR_STATUS;
/
