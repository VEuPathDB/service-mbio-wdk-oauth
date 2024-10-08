CREATE SCHEMA USERACCOUNTS

CREATE TABLE USERACCOUNTS.ACCOUNTS
   (	USER_ID BIGINT NOT NULL,
	EMAIL VARCHAR(255) NOT NULL,
	PASSWD VARCHAR(50) NOT NULL,
	IS_GUEST SMALLINT NOT NULL,
	SIGNATURE VARCHAR(40),
	STABLE_ID VARCHAR(500),
	REGISTER_TIME TIMESTAMP (6),
	LAST_LOGIN TIMESTAMP (6),
	CONSTRAINT EMAIL_UNIQ_CONSTRAINT UNIQUE (EMAIL),
	CONSTRAINT ACCOUNTS_PK PRIMARY KEY (USER_ID)
   );

CREATE SEQUENCE USERACCOUNTS.accounts_pkseq;

-- USERACCOUNTS.ACCOUNT_PROPERTIES definition

CREATE TABLE USERACCOUNTS.ACCOUNT_PROPERTIES
   (	USER_ID BIGINT,
	KEY VARCHAR(40),
	VALUE VARCHAR(4000),
	 CONSTRAINT ACCOUNT_PROPERTIES_PK PRIMARY KEY (USER_ID, KEY)
   );


CREATE TABLE USERACCOUNTS.GUEST_IDS
   (
    USER_ID NUMERIC(12,0) NOT NULL,
	CREATION_TIME TIMESTAMP (6) NOT NULL,
	 CONSTRAINT GUEST_IDS_PK PRIMARY KEY (USER_ID)
   )