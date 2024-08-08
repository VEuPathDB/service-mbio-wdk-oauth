#!/bin/bash

psql --set "SCHEMA_SUFFIX=${VDI_SCHEMA_SUFFIX}" --set="VDI_DB_PASSWD='${VDI_DB_PASSWD}'" -U ${POSTGRES_USER} -d ${POSTGRES_DB} <<-END

CREATE USER vdi_control_:SCHEMA_SUFFIX WITH PASSWORD :VDI_DB_PASSWD;

CREATE SCHEMA vdi_control_:SCHEMA_SUFFIX

CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset (
  dataset_id   VARCHAR(32)     PRIMARY KEY NOT NULL
, owner        BIGINT                      NOT NULL
, type_name    VARCHAR(64)                 NOT NULL
, type_version VARCHAR(64)                 NOT NULL
, is_deleted   SMALLINT       DEFAULT 0    NOT NULL
, is_public    BOOLEAN                     NOT NULL
);


CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset_meta (
  dataset_id  VARCHAR(32)   PRIMARY KEY NOT NULL
, name        VARCHAR(1024) NOT NULL
, description VARCHAR(4000)
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset (dataset_id)
);


CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.sync_control (
  dataset_id         VARCHAR(32)     PRIMARY KEY NOT NULL
, shares_update_time TIMESTAMP WITH TIME ZONE    NOT NULL
, data_update_time   TIMESTAMP WITH TIME ZONE    NOT NULL
, meta_update_time   TIMESTAMP WITH TIME ZONE    NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset (dataset_id)
);

CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset_install_message (
  dataset_id   VARCHAR(32) NOT NULL
, install_type VARCHAR(64) NOT NULL
, status       VARCHAR(64) NOT NULL
, message      TEXT
, updated      TIMESTAMP WITH TIME ZONE NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset (dataset_id)
, PRIMARY KEY (dataset_id, install_type)
);

-- mapping of dataset_id to user_id, including owners and accepted share offers
CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset_visibility (
  dataset_id VARCHAR(32) NOT NULL
, user_id    BIGINT   NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset (dataset_id)
, PRIMARY KEY (user_id, dataset_id)  -- user_id comes first because it is common query
);

CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset_project (
  dataset_id VARCHAR(32)     PRIMARY KEY NOT NULL
, project_id VARCHAR(64) NOT NULL
, FOREIGN KEY (dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset (dataset_id)
);

-- Install process heartbeats.  Used to track active installs and locate
-- installs that were interrupted mid-process and left in a broken state.
CREATE TABLE VDI_CONTROL_:SCHEMA_SUFFIX.dataset_install_activity (
  dataset_id   VARCHAR(32) NOT NULL
, install_type VARCHAR(64) NOT NULL
, last_update  TIMESTAMP WITH TIME ZONE NOT NULL
, FOREIGN KEY (dataset_id, install_type) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset_install_message (dataset_id, install_type)
, PRIMARY KEY (dataset_id, install_type)
);

-- convenience view showing datasets visible to a user that are fully installed, and not deleted
-- application code should use this view to find datasets a user can use
CREATE VIEW VDI_CONTROL_:SCHEMA_SUFFIX.AvailableUserDatasets AS
SELECT
    v.dataset_id as user_dataset_id,
    v.user_id,
    d.is_public,
    d.type_name as type,
    m.name,
    m.description,
    p.project_id
FROM
    VDI_CONTROL_:SCHEMA_SUFFIX.dataset d,
    VDI_CONTROL_:SCHEMA_SUFFIX.dataset_meta m,
    VDI_CONTROL_:SCHEMA_SUFFIX.dataset_project p,
    (SELECT dataset_id
     FROM VDI_CONTROL_:SCHEMA_SUFFIX.dataset_install_message
     WHERE install_type = 'meta'
     AND status = 'complete'
     INTERSECT
     SELECT dataset_id
     FROM VDI_CONTROL_:SCHEMA_SUFFIX.dataset_install_message
     WHERE install_type = 'data'
     AND status = 'complete'
    ) i,
    (SELECT dataset_id, user_id
     FROM VDI_CONTROL_:SCHEMA_SUFFIX.dataset_visibility
     UNION
     SELECT dataset_id, NULL as user_id
     FROM VDI_CONTROL_:SCHEMA_SUFFIX.dataset d
     WHERE d.is_public = '1'
    ) v
    WHERE v.dataset_id = i.dataset_id
    and v.dataset_id = d.dataset_id
    and v.dataset_id = m.dataset_id
    and v.dataset_id = p.dataset_id
    and d.is_deleted = 0;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA vdi_control_:SCHEMA_SUFFIX TO vdi_control_:SCHEMA_SUFFIX;
GRANT pg_read_server_files TO vdi_control_:SCHEMA_SUFFIX;
GRANT ALL ON SCHEMA vdi_control_:SCHEMA_SUFFIX TO vdi_control_:SCHEMA_SUFFIX;
END