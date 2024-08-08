CREATE SCHEMA edausermb

-- Contains all users who own analysis instances or preferences in this DB
CREATE TABLE edausermb.users (
  user_id bigint not null,
  is_guest boolean not null,
  preferences text,
  PRIMARY KEY (user_id)
);

-- Contains analysis instance data
CREATE TABLE edausermb.analysis (
  analysis_id varchar(50) not null,
  user_id bigint not null,
  study_id varchar(50) not null,
  study_version varchar(50),
  api_version varchar(50),
  display_name varchar(50) not null,
  description varchar(4000),
  creation_time timestamp not null,
  modification_time timestamp not null,
  is_public boolean not null,
  num_filters smallint not null,
  num_computations smallint not null,
  num_visualizations smallint not null,
  analysis_descriptor text,
  notes text,
  provenance text,
  PRIMARY KEY (analysis_id)
);
ALTER TABLE edausermb.analysis ADD FOREIGN KEY (user_id) REFERENCES edausermb.users (user_id);
CREATE INDEX analysis_user_id_idx ON edausermb.analysis (user_id);

CREATE TABLE edausermb.derived_variables (
  variable_id   VARCHAR(36) NOT NULL,
  user_id       bigint NOT NULL,
  dataset_id    VARCHAR(50) NOT NULL,
  entity_id     VARCHAR(50) NOT NULL,
  display_name  VARCHAR(256) NOT NULL,
  description   VARCHAR(4000),
  provenance    text,
  function_name VARCHAR(256) NOT NULL,
  config        text NOT NULL,
  PRIMARY KEY (variable_id, user_id)
);

ALTER TABLE edausermb.derived_variables ADD FOREIGN KEY (user_id) REFERENCES edausermb.users(user_id);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA edausermb TO vdi_control_dev_n;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA edausermb TO vdi_datasets_dev_n;