CREATE SCHEMA studyaccess;

-- studyaccess.approval_status

CREATE TABLE studyaccess.approval_status
(
  approval_status_id SMALLINT PRIMARY KEY,
  name               VARCHAR(24) NOT NULL
);

-- studyaccess.restriction_level

CREATE TABLE studyaccess.restriction_level
(
  restriction_level_id SMALLSERIAL CONSTRAINT restriction_level_pk PRIMARY KEY,
  name                 VARCHAR(24) UNIQUE NOT NULL
);

-- studyaccess.staff

CREATE TABLE studyaccess.staff
(
  staff_id BIGSERIAL
    CONSTRAINT staff_pk PRIMARY KEY,
  user_id  BIGINT          NOT NULL UNIQUE,
  is_owner SMALLINT DEFAULT 0 NOT NULL CHECK ( is_owner = 0 OR is_owner = 1 )
);

-- studyaccess.providers

CREATE TABLE studyaccess.providers
(
  provider_id BIGSERIAL
    CONSTRAINT providers_pk PRIMARY KEY,
  user_id     BIGINT          NOT NULL,
  is_manager  SMALLINT DEFAULT 0 NOT NULL CHECK ( is_manager = 0 OR is_manager = 1 ),
  dataset_id  VARCHAR(15)        NOT NULL,
  CONSTRAINT provider_user_ds_uq UNIQUE (user_id, dataset_id)
);

-- studyaccess.end_users

CREATE TABLE studyaccess.end_users
(
  end_user_id          BIGSERIAL
    CONSTRAINT end_users_pk PRIMARY KEY,
  user_id              BIGINT                                         NOT NULL,
  dataset_presenter_id VARCHAR(15)                                       NOT NULL,
  restriction_level_id SMALLINT                                          NOT NULL
    REFERENCES studyaccess.restriction_level (restriction_level_id),
  approval_status_id   SMALLINT                DEFAULT 1                 NOT NULL
    REFERENCES studyaccess.approval_status (approval_status_id),
  start_date           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  duration             BIGINT               DEFAULT -1                NOT NULL,
  purpose              VARCHAR(4000),
  research_question    VARCHAR(4000),
  analysis_plan        VARCHAR(4000),
  dissemination_plan   VARCHAR(4000),
  prior_auth           VARCHAR(4000),
  denial_reason        VARCHAR(4000),
  date_denied          TIMESTAMP WITH TIME ZONE,
  allow_self_edits     SMALLINT                DEFAULT 0                 NOT NULL,
  CONSTRAINT end_user_ds_user_uq UNIQUE (user_id, dataset_presenter_id)
);

-- studyaccess.end_user_history
CREATE TABLE studyaccess.end_user_history
(
  end_user_id          BIGINT                                         NOT NULL,
  user_id              BIGINT                                         NOT NULL,
  dataset_presenter_id VARCHAR(15)                                       NOT NULL,
  -- Action taken on the record, should be one of: CREATE, UPDATE, or DELETE
  history_action       VARCHAR(6)                                        NOT NULL,
  -- Timestamp of the change to the studyaccess.end_users table
  history_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  -- User who made the change to the studyaccess.end_users table.
  history_cause_user   BIGINT                                         NOT NULL,
  restriction_level_id SMALLINT                                          NOT NULL
    REFERENCES studyaccess.restriction_level (restriction_level_id),
  approval_status_id   SMALLINT                                          NOT NULL
    REFERENCES studyaccess.approval_status (approval_status_id),
  start_date           TIMESTAMP WITH TIME ZONE                           NOT NULL,
  duration             BIGINT                                         NOT NULL,
  purpose              VARCHAR(4000),
  research_question    VARCHAR(4000),
  analysis_plan        VARCHAR(4000),
  dissemination_plan   VARCHAR(4000),
  prior_auth           VARCHAR(4000),
  denial_reason        VARCHAR(4000),
  date_denied          TIMESTAMP WITH TIME ZONE,
  allow_self_edits     SMALLINT                                          NOT NULL
);