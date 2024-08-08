#!/bin/bash



psql --set "SCHEMA_SUFFIX=${VDI_SCHEMA_SUFFIX}" --set="VDI_DB_PASSWD='${VDI_DB_PASSWD}'" -U ${POSTGRES_USER} -d ${POSTGRES_DB} <<-END
CREATE USER vdi_datasets_:SCHEMA_SUFFIX WITH PASSWORD :VDI_DB_PASSWD;

CREATE SCHEMA VDI_DATASETS_:SCHEMA_SUFFIX;

CREATE TABLE VDI_DATASETS_:SCHEMA_SUFFIX.Study (
 user_dataset_id     VARCHAR(32),
 stable_id                         VARCHAR(200) NOT NULL,
 internal_abbrev              VARCHAR(75),
 modification_date            DATE NOT NULL,
 PRIMARY KEY (stable_id),
 UNIQUE(user_dataset_id),
  FOREIGN KEY (user_dataset_id) REFERENCES VDI_CONTROL_:SCHEMA_SUFFIX.dataset(dataset_id));

CREATE SEQUENCE VDI_DATASETS_:SCHEMA_SUFFIX.Study_sq;

-----------------------------------------------------------

CREATE TABLE VDI_DATASETS_:SCHEMA_SUFFIX.EntityTypeGraph (
 stable_id                    VARCHAR(255),
 study_stable_id                VARCHAR(200),
 parent_stable_id             VARCHAR(255),
 internal_abbrev              VARCHAR(50) NOT NULL,
  description                  VARCHAR(4000),
 display_name                 VARCHAR(200) NOT NULL,
 display_name_plural          VARCHAR(200),
 has_attribute_collections    NUMERIC(1),
 is_many_to_one_with_parent   NUMERIC(1),
 cardinality                  NUMERIC(38,0),
 PRIMARY KEY (stable_id, study_stable_id)
);

CREATE SEQUENCE VDI_DATASETS_:SCHEMA_SUFFIX.EntityTypeGraph_sq;

-----------------------------------------------------------


CREATE VIEW  VDI_DATASETS_:SCHEMA_SUFFIX.UserStudyDatasetId as
SELECT CONCAT('EDAUD_', user_dataset_id) as dataset_stable_id, stable_id as study_stable_id
FROM VDI_DATASETS_:SCHEMA_SUFFIX.study;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA vdi_datasets_:SCHEMA_SUFFIX TO vdi_control_:SCHEMA_SUFFIX;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA vdi_datasets_:SCHEMA_SUFFIX TO vdi_datasets_:SCHEMA_SUFFIX;
GRANT ALL ON SCHEMA vdi_datasets_:SCHEMA_SUFFIX TO vdi_datasets_:SCHEMA_SUFFIX;
END