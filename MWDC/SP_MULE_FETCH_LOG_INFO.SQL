CREATE OR REPLACE PROCEDURE IIW.SP_MULE_FETCH_LOG_INFO(I_INTERFACE_NAME IN VARCHAR2, O_STATUS OUT NUMBER, O_MSG OUT VARCHAR2, O_TEMPTABLE Out VARCHAR2,O_PRJ_NAME Out VARCHAR2/*,  O_SUCES_ST OUT NUMBER*/)
IS

  CURSOR C1(TAB_NAME VARCHAR2) IS
SELECT TABLE_NAME FROM USER_TABLES WHERE UPPER(TABLE_NAME)= UPPER(TAB_NAME);
CR1 C1%ROWTYPE;

P_QUERY VARCHAR2(1000);
S_QUERY VARCHAR2(4000);
TempTabl VARCHAR2(100);
V_PrjStatus Number := 1;
V_LASTRUN_c varchar2(100) ;
v_lastrun timestamp (6);
v_lastrunmsg varchar2(100);
v_cur_log_time  timestamp (6);
V_PRJ_NAME VARCHAR2(50);
V_MAXDATE VARCHAR2(15);
V_COUNT NUMBER;
--V_SUCESS_ST NUMBER := 0;
BEGIN


BEGIN 
SELECT UPPER(PROJECT_NAME) INTO V_PRJ_NAME FROM TBL_DATA_MASTER WHERE UPPER(INTERFACE_ID) =TRIM(UPPER( I_INTERFACE_NAME));
EXCEPTION
WHEN NO_DATA_FOUND THEN
V_PRJ_NAME := NULL;
END;
DBMS_OUTPUT.PUT_LINE('V_PRJ_NAME : ' || V_PRJ_NAME);
TempTabl := 'TEMP_LOG_INFO_LOAD';
O_PRJ_NAME:=V_PRJ_NAME;

EXECUTE IMMEDIATE 'Truncate TABLE TEMP_LOG_INFO_LOAD';

begin
 select status_1 INTO  V_PrjStatus from(
 SELECT DECODE(STATUS, 'C', '1', 'E', '1', '0' ) status_1 from tbl_etl_route_details where upper(interface_id) in (
 select UPPER(INTERFACE_ID) from   TBL_DATA_MASTER where UPPER(project_name) =UPPER(V_PRJ_NAME) ) 
 order by 1 ) where  rownum =1;
exception
when others then 
DBMS_OUTPUT.PUT_LINE('EXEC: ' || SQLERRM);
V_PrjStatus := null;
end;



If V_PrjStatus = 1 then

begin
select log_time_stamp_P INTO V_LASTRUN from TEMP_PRV_LOG_RUN where UPPER(project_name)  = V_PRJ_NAME ;
select to_char(log_time_stamp_P, 'FMDy, FMDD  HH12:MI:SS') INTO V_LASTRUN_C from TEMP_PRV_LOG_RUN where UPPER(project_name)  = V_PRJ_NAME ;
exception
when no_data_found then
V_LASTRUN := null;
dbms_output.put_line(sqlerrm);
when others then
V_LASTRUN := null;
dbms_output.put_line(sqlerrm);
end;
dbms_output.put_line('V_LASTRUN ' || v_lastrun );

S_QUERY := 'INSERT INTO  temp_log_info_load  
select to_char(log_time_stamp, ''FMDy, FMDD  HH12:MI:SS''), to_char( log_data) , to_char(error_details), b.interface_id, b.PROJECT_NAME  from tbl_log_info a, TBL_DATA_MASTER b where
upper(a.interface_id) = UPPER(b.INTERFACE_ID) AND TO_CHAR(LOG_TIME_STAMP,''DD/MM/YYYY'') = TO_CHAR(SYSDATE, ''DD/MM/YYYY'') 
and UPPER(b.project_name) =UPPER( ''' || V_PRJ_NAME || ''')';

IF V_LASTRUN IS NOT NULL THEN
S_QUERY := S_QUERY ||  ' AND A.LOG_TIME_STAMP > ( ''' || V_LASTRUN || ''')';  
END IF;
dbms_output.put_line(S_QUERY);

EXECUTE IMMEDIATE S_QUERY;
commit;

EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM temp_log_info_load ' INTO V_COUNT;
dbms_output.put_line('Inserted COUNT : ' || V_COUNT);
begin

select MAX(log_time_stamp) INTO v_cur_log_time from tbl_log_info a, TBL_DATA_MASTER b where
upper(a.interface_id) = UPPER(b.INTERFACE_ID) AND TO_CHAR(LOG_TIME_STAMP,'DD/MM/YYYY') =  TO_CHAR(SYSDATE, 'DD/MM/YYYY')  
and UPPER(b.project_name) =UPPER( V_PRJ_NAME );

exception
when no_data_found then
v_cur_log_time := null;
dbms_output.put_line(sqlerrm);
end;

dbms_output.put_line('v_cur_log_time ' || v_cur_log_time);

if V_LASTRUN is not null then
v_lastrunMSG := 'The  project was last run on : ' ||v_lastrun_C;
INSERT INTO temp_log_info_load  values ( null , v_lastrunMSG , null, null,  V_PRJ_NAME) ;
 commit;

UPDATE TEMP_PRV_LOG_RUN SET LOG_TIME_STAMP_P =  v_cur_log_time  
WHERE PROJECT_NAME =   V_PRJ_NAME ;
COMMIT;
else
INSERT INTO TEMP_PRV_LOG_RUN VALUES (v_cur_log_time, V_PRJ_NAME);
COMMIT;
end if;
end if;


/*IF V_PRJ_NAME = 'ABI_MULE_STOCK_ITEMS' THEN
begin
 select status_1 INTO  V_SUCESS_ST from(
 SELECT DECODE(STATUS, 'C', '1', '0' ) status_1 from tbl_etl_route_details where upper(interface_id) in (
 select UPPER(INTERFACE_ID) from   TBL_DATA_MASTER where UPPER(project_name) =UPPER(V_PRJ_NAME) ) 
 order by 1 ) where  rownum =1;
exception
when others then 
DBMS_OUTPUT.PUT_LINE('EXEC: ' || SQLERRM);
V_SUCESS_ST := 0;
end;
END IF;

IF V_PRJ_NAME = 'ABI_MULE_DAILY_CUR_LOAD' THEN
begin
 select status_1 INTO  V_SUCESS_ST from(
 SELECT DECODE(STATUS, 'C', '2', '0' ) status_1 from tbl_etl_route_details where upper(interface_id) in (
 select UPPER(INTERFACE_ID) from   TBL_DATA_MASTER where UPPER(project_name) =UPPER(V_PRJ_NAME) ) 
 order by 1 ) where  rownum =1;
exception
when others then 
DBMS_OUTPUT.PUT_LINE('EXEC: ' || SQLERRM);
V_SUCESS_ST := 0;
end;
END IF;*/

o_status := V_PrjStatus;
O_MSG := SQLERRM;
O_TEMPTABLE := TempTabl;
O_PRJ_NAME:=V_PRJ_NAME;
--O_SUCES_ST := V_SUCESS_ST;
EXCEPTION 
WHEN OTHERS THEN
dbms_output.put_line(sqlerrm);
O_STATUS := 0;
O_MSG := SQLERRM;
O_PRJ_NAME:=V_PRJ_NAME;
END;
/
