SET DEFINE OFF;

CREATE TABLE AUTHORITIES
(
  AUTHORITY_ID  INTEGER,
  AUTHORITY     VARCHAR2(1000 BYTE),
  USERNAME      VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_DATA_MASTER
(
  SEQUENCE_ID   INTEGER,
  INTERFACE_ID  VARCHAR2(50 BYTE),
  PROJECT_NAME  VARCHAR2(50 BYTE),
  PARTNER_NAME  VARCHAR2(50 BYTE),
  IS_ETL        CHAR(1 BYTE),
  ENV           VARCHAR2(100 BYTE)
);



CREATE TABLE TBL_ENRICHMENT
(
  SEQUENCE_ID   NUMBER(10),
  INTERFACE_ID  VARCHAR2(50 BYTE),
  PARTNER_ID    VARCHAR2(50 BYTE),
  ENRICH_KEY    VARCHAR2(50 BYTE),
  ENRICH_VALUE  VARCHAR2(100 BYTE),
  ENV           VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_ENVLIST
(
  ENVIRONMENT  VARCHAR2(20 BYTE)
);


CREATE TABLE TBL_ETL_ROUTE_DETAILS
(
  INTERFACE_ID      VARCHAR2(80 BYTE)           DEFAULT NULL,
  FILE_NAME         VARCHAR2(500 BYTE)          DEFAULT NULL,
  SP_NAME           VARCHAR2(80 BYTE)           DEFAULT NULL,
  SP_STG_STRING1    VARCHAR2(2000 BYTE)         DEFAULT NULL,
  SP_REF_STRING1    VARCHAR2(2000 BYTE)         DEFAULT NULL,
  SP_OPERATION      VARCHAR2(80 BYTE)           DEFAULT NULL,
  STATUS            CHAR(1 BYTE),
  STG_TABLE         VARCHAR2(500 BYTE)          DEFAULT NULL,
  SEQUENCE_ID       INTEGER,
  IS_DEPENDENT      CHAR(1 BYTE),
  OUTPUT_FILE_NAME  VARCHAR2(500 BYTE),
  TEMP_TBL_QUERY    VARCHAR2(2000 BYTE),
  ENV               VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_LOG_INFO
(
  LOG_ID              NUMBER(10),
  SEQUENCE_ID         NUMBER(10),
  PROCESS_ID          VARCHAR2(50 BYTE),
  PROCESS_NAME        VARCHAR2(50 BYTE),
  ACTIVITY_NAME       VARCHAR2(50 BYTE),
  APP_ID              NUMBER(10),
  APP_NAME            VARCHAR2(50 BYTE),
  LOG_TIME_STAMP      TIMESTAMP(6),
  LOG_INFO            VARCHAR2(50 BYTE),
  LOG_LEVEL           VARCHAR2(50 BYTE),
  LOG_CODE            CLOB,
  LOG_DATA            CLOB,
  ERROR_DETAILS       CLOB,
  PROCESS_STACKTRACE  CLOB,
  BUSINESSKEY1_NAME   VARCHAR2(50 BYTE),
  BUSINESSKEY_VALUE   VARCHAR2(50 BYTE),
  ENV_NAME            VARCHAR2(50 BYTE),
  INTERFACE_ID        VARCHAR2(50 BYTE),
  PROJECT_NAME        VARCHAR2(50 BYTE),
  MESSAGE_ID          VARCHAR2(50 BYTE),
  PAYLOAD             VARCHAR2(4000 BYTE),
  ENV                 VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_RECEIVER_MASTER
(
  RECEIVER_SEQUENCE_ID   NUMBER(10),
  INTERFACE_ID           VARCHAR2(50 BYTE),
  RECEIVER_ID            VARCHAR2(50 BYTE),
  PARTNER_NAME           VARCHAR2(50 BYTE),
  PROJECT_NAME           VARCHAR2(50 BYTE),
  CUSTOM_VALIDATION      CHAR(1 BYTE),
  WB_VALIDATION          CHAR(1 BYTE),
  CUSTOM_ENRICHMENT      CHAR(1 BYTE),
  WB_ENRICHMENT          CHAR(1 BYTE),
  CUSTOM_TRANSFORMATION  CHAR(1 BYTE),
  WB_TRANSFORMATION      CHAR(1 BYTE),
  CUSTOM_ROUTING         CHAR(1 BYTE),
  WB_ROUTING             CHAR(1 BYTE),
  ACK_ONDELIVER_CHK      CHAR(1 BYTE),
  ENV                    VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_ROUTING
(
  SEQUENCE_ID    NUMBER(10),
  INTERFACE_ID   VARCHAR2(50 BYTE),
  PARTNER_ID     VARCHAR2(50 BYTE),
  ROUTING_VALUE  VARCHAR2(50 BYTE),
  ENV            VARCHAR2(100 BYTE)
);

CREATE TABLE TBL_SENDER_MASTER
(
  SENDER_SEQUENCE_ID     NUMBER(10),
  INTERFACE_ID           VARCHAR2(50 BYTE),
  SENDER_ID              VARCHAR2(50 BYTE),
  PROJECT_NAME           VARCHAR2(50 BYTE),
  PARTNER_NAME           VARCHAR2(50 BYTE),
  CUSTOM_VALIDATION      CHAR(1 BYTE),
  WB_VALIDATION          CHAR(1 BYTE),
  CUSTOM_ENRICHMENT      CHAR(1 BYTE),
  WB_ENRICHMENT          CHAR(1 BYTE),
  CUSTOM_TRANSFORMATION  CHAR(1 BYTE),
  WB_TRANSFORMATION      CHAR(1 BYTE),
  CUSTOM_ROUTING         CHAR(1 BYTE),
  WB_ROUTING             CHAR(1 BYTE),
  ACK_ONARRIVAL          CHAR(1 BYTE),
  ENV                    VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_SPLIT_STATUS
(
  FILENAME        VARCHAR2(1000 BYTE),
  SPLIT_FILENAME  VARCHAR2(1000 BYTE),
  STATUS          CHAR(1 BYTE)
);


CREATE TABLE TBL_TRANSFORMATION
(
  SEQUENCE_ID        NUMBER(10),
  INTERFACE_ID       VARCHAR2(50 BYTE),
  PARTNER_ID         VARCHAR2(50 BYTE),
  XSLT_FILE          CLOB,
  STATUS             VARCHAR2(10 BYTE),
  XSD_FILE           CLOB,
  ROUTING_XSLT_FILE  CLOB,
  ENV                VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_TRANSPORTS
(
  SEQUENCE_ID         NUMBER(10),
  INTERFACE_ID        VARCHAR2(50 BYTE),
  PARTNER_ID          VARCHAR2(50 BYTE),
  TRANSPORT_TYPE      VARCHAR2(50 BYTE),
  INPUT_DESTINATION   VARCHAR2(50 BYTE),
  OUTPUT_DESTINATION  VARCHAR2(50 BYTE),
  ENV                 VARCHAR2(100 BYTE)
);


CREATE TABLE TBL_TRANSPORT_DATA
(
  SEQUENCE_ID     NUMBER,
  TRANSPORT_ID    NUMBER,
  TRANSPORT_NAME  VARCHAR2(50 BYTE)
);


CREATE TABLE TBL_VALIDATION
(
  SEQUENCE_ID   NUMBER(10),
  INTERFACE_ID  VARCHAR2(50 BYTE),
  PARTNER_ID    VARCHAR2(50 BYTE),
  XSD_FILE      CLOB,
  STATUS        VARCHAR2(10 BYTE),
  ENV           VARCHAR2(100 BYTE)
);

CREATE TABLE TEMP_LOG_INFO_LOAD
(
  LOG_TIME_STAMP  VARCHAR2(200 BYTE),
  LOG_DATA        VARCHAR2(4000 BYTE),
  ERROR_DETAILS   VARCHAR2(4000 BYTE),
  INTERFACE_ID    VARCHAR2(50 BYTE),
  PROJECT_NAME    VARCHAR2(50 BYTE)
);


CREATE TABLE TEMP_PRV_LOG_RUN
(
  LOG_TIME_STAMP_P  TIMESTAMP(6),
  PROJECT_NAME      VARCHAR2(50 BYTE)
);


CREATE TABLE USERS
(
  USERNAME    VARCHAR2(100 BYTE),
  PASSWORD    VARCHAR2(100 BYTE),
  FIRST_NAME  VARCHAR2(100 BYTE),
  LAST_NAME   VARCHAR2(100 BYTE),
  ENABLED     NUMBER
);

Insert into TBL_TRANSPORT_DATA
   (SEQUENCE_ID, TRANSPORT_ID, TRANSPORT_NAME)
Values
   (5, 5, 'HTTP');
Insert into TBL_TRANSPORT_DATA
   (SEQUENCE_ID, TRANSPORT_ID, TRANSPORT_NAME)
Values
   (6, 6, 'HTTPS');
Insert into TBL_TRANSPORT_DATA
   (SEQUENCE_ID, TRANSPORT_ID, TRANSPORT_NAME)
Values
   (3, 3, 'JMS');
Insert into TBL_TRANSPORT_DATA
   (SEQUENCE_ID, TRANSPORT_ID, TRANSPORT_NAME)
Values
   (1, 1, 'FILE');
Insert into TBL_TRANSPORT_DATA
   (SEQUENCE_ID, TRANSPORT_ID, TRANSPORT_NAME)
Values
   (2, 2, 'DATABASE');
COMMIT;


INSERT INTO TBL_ENVLIST VALUES('DEV');
INSERT INTO TBL_ENVLIST VALUES('TEST');
INSERT INTO TBL_ENVLIST VALUES('UAT');

COMMIT;

insert into AUTHORITIES values(1,'ROLE_SUPER_ADMIN','admin');

insert into USERS(USERNAME,PASSWORD,FIRST_NAME,LAST_NAME) values('admin','$2a$10$0i2ZSbEBbgTuDTq/FOV2xeSpfGQ4cUtwxHalX1MQUU7QSNirmP86C','admin','admin');

COMMIT;
 