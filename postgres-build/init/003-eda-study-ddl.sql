-- set CONCAT OFF;

-- so the foreign key constraints are allowed
-- grant references on &2.OntologyTerm to &1;
-- grant references on &2.ExternalDatabaseRelease to &1;

CREATE SCHEMA EDA;

CREATE TABLE EDA.Study (
 study_id            NUMERIC(12) NOT NULL,
 stable_id                         VARCHAR(200) NOT NULL,
 external_database_release_id numeric(10) NOT NULL,
 internal_abbrev              varchar(75),
 max_attr_length              numeric(4),
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 PRIMARY KEY (study_id),
 CONSTRAINT unique_stable_id UNIQUE (stable_id)
);

CREATE SEQUENCE EDA.Study_sq;

CREATE INDEX study_ix_1 ON EDA.study (external_database_release_id, stable_id, internal_abbrev, study_id) ;

-----------------------------------------------------------

CREATE TABLE EDA.EntityType (
 entity_type_id            NUMERIC(12) NOT NULL,
 name                      VARCHAR(200) NOT NULL,
 type_id                   NUMERIC(10),
 isa_type                     VARCHAR(50),
 study_id            NUMERIC(12) NOT NULL,
 internal_abbrev              VARCHAR(50) NOT NULL,
 cardinality                  NUMERIC(38,0),
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (study_id) REFERENCES EDA.study,
 PRIMARY KEY (entity_type_id)
);

CREATE SEQUENCE EDA.EntityType_sq;

CREATE UNIQUE INDEX entitytype_ix_1 ON EDA.entitytype (study_id, entity_type_id) ;
CREATE UNIQUE INDEX entitytype_ix_2 ON EDA.entitytype (type_id, entity_type_id) ;
CREATE UNIQUE INDEX entitytype_ix_3 ON EDA.entitytype (study_id, internal_abbrev) ;

-----------------------------------------------------------

CREATE TABLE EDA.ProcessType (
 process_type_id            NUMERIC(12) NOT NULL,
 name                         VARCHAR(200) NOT NULL,
 description                  VARCHAR(4000),
 type_id                      NUMERIC(10),
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 PRIMARY KEY (process_type_id)
);

CREATE SEQUENCE EDA.ProcessType_sq;

CREATE INDEX processtype_ix_1 ON EDA.processtype (type_id, process_type_id) ;

-----------------------------------------------------------

CREATE TABLE EDA.EntityAttributes (
 entity_attributes_id         NUMERIC(12) NOT NULL,
 stable_id                    VARCHAR(200) NOT NULL,
 entity_type_id               NUMERIC(12) NOT NULL,
 atts                         TEXT,
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 PRIMARY KEY (entity_attributes_id),
FOREIGN KEY (entity_type_id) REFERENCES EDA.EntityType (entity_type_id) --,
--CONSTRAINT ensure_va_json CHECK (atts is json)
);

-- 
--CREATE SEARCH INDEX EDA.va_search_ix ON EDA.entityattributes (atts) FOR JSON;

CREATE INDEX entityattributes_ix_1 ON EDA.entityattributes (entity_type_id, entity_attributes_id) ;

CREATE SEQUENCE EDA.EntityAttributes_sq;

-----------------------------------------------------------

CREATE TABLE EDA.EntityClassification (
 entity_classification_id         NUMERIC(12) NOT NULL,
 entity_attributes_id         NUMERIC(12) NOT NULL,
 entity_type_id               NUMERIC(12) NOT NULL,
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (entity_type_id) REFERENCES EDA.EntityType (entity_type_id),
 FOREIGN KEY (entity_attributes_id) REFERENCES EDA.EntityAttributes (entity_attributes_id),
 PRIMARY KEY (entity_classification_id)
);

CREATE INDEX entityclassification_ix_1 ON EDA.entityclassification (entity_type_id, entity_attributes_id) ;
CREATE INDEX entityclassification_ix_2 ON EDA.entityclassification (entity_attributes_id, entity_type_id) ;

CREATE SEQUENCE EDA.EntityClassification_sq;

-----------------------------------------------------------

CREATE TABLE EDA.ProcessAttributes (
 process_attributes_id           NUMERIC(12) NOT NULL,
 process_type_id                NUMERIC(12) NOT NULL,
 in_entity_id                 NUMERIC(12) NOT NULL,
 out_entity_id                NUMERIC(12) NOT NULL,
 atts                         TEXT,
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (in_entity_id) REFERENCES EDA.entityattributes (entity_attributes_id),
 FOREIGN KEY (out_entity_id) REFERENCES EDA.entityattributes (entity_attributes_id),
 FOREIGN KEY (process_type_id) REFERENCES EDA.processtype (process_type_id),
 PRIMARY KEY (process_attributes_id) -- ,
--  CONSTRAINT ensure_ea_json CHECK (atts is json)   
);

CREATE INDEX ea_in_ix ON EDA.processattributes (in_entity_id, out_entity_id, process_attributes_id) ;
CREATE INDEX ea_out_ix ON EDA.processattributes (out_entity_id, in_entity_id, process_attributes_id) ;

CREATE INDEX ea_ix_1 ON EDA.processattributes (process_type_id, process_attributes_id) ;

CREATE SEQUENCE EDA.ProcessAttributes_sq;

-----------------------------------------------------------

CREATE TABLE EDA.EntityTypeGraph (
 entity_type_graph_id           NUMERIC(12) NOT NULL,
 study_id                       NUMERIC(12) NOT NULL,
 study_stable_id                varchar(200),
 parent_stable_id             varchar(255),
 parent_id                    NUMERIC(12),
 stable_id                    varchar(255),
 entity_type_id                NUMERIC(12) NOT NULL,
 display_name                 VARCHAR(200) NOT NULL,
 display_name_plural          VARCHAR(200),
 description                  VARCHAR(4000),
 internal_abbrev              VARCHAR(50) NOT NULL,
 has_attribute_collections    NUMERIC(1),
 is_many_to_one_with_parent   NUMERIC(1),
 cardinality                  NUMERIC(38,0),
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (study_id) REFERENCES EDA.study (study_id),
 FOREIGN KEY (parent_id) REFERENCES EDA.entitytype (entity_type_id),
 FOREIGN KEY (entity_type_id) REFERENCES EDA.entitytype (entity_type_id),
 PRIMARY KEY (entity_type_graph_id)
);

CREATE SEQUENCE EDA.EntityTypeGraph_sq;

CREATE INDEX entitytypegraph_ix_1 ON EDA.entitytypegraph (study_id, entity_type_id, parent_id, entity_type_graph_id) ;
CREATE INDEX entitytypegraph_ix_2 ON EDA.entitytypegraph (parent_id, entity_type_graph_id) ;
CREATE INDEX entitytypegraph_ix_3 ON EDA.entitytypegraph (entity_type_id, entity_type_graph_id) ;

-----------------------------------------------------------

CREATE TABLE EDA.AttributeUnit (
 attribute_unit_id                NUMERIC(12) NOT NULL,
 entity_type_id                      NUMERIC(12) NOT NULL,
 attr_ontology_term_id               NUMERIC(10) NOT NULL,
 unit_ontology_term_id               NUMERIC(10) NOT NULL,
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (entity_type_id) REFERENCES EDA.EntityType,
 PRIMARY KEY (attribute_unit_id)
);

CREATE SEQUENCE EDA.AttributeUnit_sq;

CREATE INDEX attributeunit_ix_1 ON EDA.attributeunit (entity_type_id, attr_ontology_term_id, unit_ontology_term_id, attribute_unit_id) ;
CREATE INDEX attributeunit_ix_2 ON EDA.attributeunit (attr_ontology_term_id, attribute_unit_id) ;
CREATE INDEX attributeunit_ix_3 ON EDA.attributeunit (unit_ontology_term_id, attribute_unit_id) ;

-----------------------------------------------------------


CREATE TABLE EDA.ProcessTypeComponent (
 process_type_component_id       NUMERIC(12) NOT NULL,
 process_type_id                 NUMERIC(12) NOT NULL,
 component_id                 NUMERIC(12) NOT NULL,
 order_num                    NUMERIC(2) NOT NULL,
 modification_date            TIMESTAMP NOT NULL,
 user_read                    NUMERIC(1) NOT NULL,
 user_write                   NUMERIC(1) NOT NULL,
 group_read                   NUMERIC(1) NOT NULL,
 group_write                  NUMERIC(1) NOT NULL,
 other_read                   NUMERIC(1) NOT NULL,
 other_write                  NUMERIC(1) NOT NULL,
 row_user_id                  NUMERIC(12) NOT NULL,
 row_group_id                 NUMERIC(3) NOT NULL,
 row_project_id               NUMERIC(4) NOT NULL,
 row_alg_invocation_id        NUMERIC(12) NOT NULL,
 FOREIGN KEY (process_type_id) REFERENCES EDA.ProcessType (process_type_id),
 FOREIGN KEY (component_id) REFERENCES EDA.ProcessType (process_type_id),
 PRIMARY KEY (process_type_component_id)
);

CREATE SEQUENCE EDA.ProcessTypeComponent_sq;

CREATE INDEX ptc_ix_1 ON EDA.processtypecomponent (process_type_id, component_id, order_num, process_type_component_id) ;
CREATE INDEX ptc_ix_2 ON EDA.processtypecomponent (component_id, process_type_component_id) ;

-----------------------------------------------------------


CREATE TABLE EDA.Attribute (
  attribute_id                  NUMERIC(12) NOT NULL,
  entity_type_id                NUMERIC(12) not null,
  entity_type_stable_id         varchar(255),
  process_type_id                 NUMERIC(12),
  ontology_term_id         NUMERIC(10),
  parent_stable_id         varchar(255),
--parent_ontology_term_id         NUMERIC(10) NOT NULL,
  stable_id varchar(255) NOT NULL,
  non_ontological_name                  varchar(1500),
  data_type                    varchar(10) not null,
  distinct_values_count            integer,
  is_multi_valued                numeric(1),
  data_shape                     varchar(30),
  unit                          varchar(400),
  unit_ontology_term_id         NUMERIC(10),
  precision                     integer,
  ordered_values                TEXT,
  range_min                     varchar(16),
  range_max                     varchar(16),
  bin_width                    varchar(16),
  mean                          varchar(16),
  median                        varchar(16),
  lower_quartile               varchar(16),
  upper_quartile               varchar(16),
  modification_date            TIMESTAMP NOT NULL,
  user_read                    NUMERIC(1) NOT NULL,
  user_write                   NUMERIC(1) NOT NULL,
  group_read                   NUMERIC(1) NOT NULL,
  group_write                  NUMERIC(1) NOT NULL,
  other_read                   NUMERIC(1) NOT NULL,
  other_write                  NUMERIC(1) NOT NULL,
  row_user_id                  NUMERIC(12) NOT NULL,
  row_group_id                 NUMERIC(3) NOT NULL,
  row_project_id               NUMERIC(4) NOT NULL,
  row_alg_invocation_id        NUMERIC(12) NOT NULL,
  FOREIGN KEY (entity_type_id) REFERENCES EDA.EntityType (entity_type_id),
  FOREIGN KEY (process_type_id) REFERENCES EDA.ProcessType (process_type_id),
  PRIMARY KEY (attribute_id) -- ,
--  CONSTRAINT ensure_ov_json CHECK (ordered_values is json)   
);

CREATE SEQUENCE EDA.Attribute_sq;

CREATE INDEX attribute_ix_1 ON EDA.attribute (entity_type_id, process_type_id, stable_id, attribute_id) ;

-----------------------------------------------------------

CREATE TABLE EDA.AttributeGraph (
  attribute_graph_id                  NUMERIC(12) NOT NULL,
  study_id            NUMERIC(12) NOT NULL, 
  ontology_term_id         NUMERIC(10),
  stable_id                varchar(255) NOT NULL,
  parent_stable_id              varchar(255) NOT NULL,
  parent_ontology_term_id       NUMERIC(10) NOT NULL,
  provider_label                varchar(4000),
  display_name                  varchar(1500) not null,
  display_order                numeric(3),
  definition                   varchar(4000),
  display_type                    varchar(20),
  hidden                   varchar(64),
  display_range_min            varchar(16),
  display_range_max            varchar(16),
  is_merge_key                 numeric(1),
  force_string_type            varchar(10),
  variable_spec_to_impute_zeroes_for     varchar(200),
  has_study_dependent_vocabulary         numeric(1),
  weighting_variable_spec                varchar(200),
  impute_zero                  numeric(1),
  is_repeated                  numeric(1),
  bin_width_override           varchar(16),
  is_temporal                  numeric(1),
  is_featured                  numeric(1),
  ordinal_values               TEXT,
  scale                         varchar(30),
  modification_date            TIMESTAMP NOT NULL,
  user_read                    NUMERIC(1) NOT NULL,
  user_write                   NUMERIC(1) NOT NULL,
  group_read                   NUMERIC(1) NOT NULL,
  group_write                  NUMERIC(1) NOT NULL,
  other_read                   NUMERIC(1) NOT NULL,
  other_write                  NUMERIC(1) NOT NULL,
  row_user_id                  NUMERIC(12) NOT NULL,
  row_group_id                 NUMERIC(3) NOT NULL,
  row_project_id               NUMERIC(4) NOT NULL,
  row_alg_invocation_id        NUMERIC(12) NOT NULL,
  FOREIGN KEY (study_id) REFERENCES EDA.study (study_id),
  PRIMARY KEY (attribute_graph_id) -- ,
--  CONSTRAINT ensure_ordv_json CHECK (ordinal_values is json),
--  CONSTRAINT ensure_prolbl_json CHECK (provider_label is json)
);

CREATE SEQUENCE EDA.AttributeGraph_sq;

CREATE INDEX attributegraph_ix_1 ON EDA.attributegraph (study_id, ontology_term_id, parent_ontology_term_id, attribute_graph_id) ;


CREATE TABLE EDA.StudyCharacteristic (
  study_characteristic_id      NUMERIC(5) NOT NULL,
  study_id                     NUMERIC(12) NOT NULL, 
  attribute_id                 NUMERIC(12) NOT NULL,
  value_ontology_term_id       NUMERIC(10),
  value                        VARCHAR(300) NOT NULL,
  modification_date            TIMESTAMP NOT NULL,
  user_read                    NUMERIC(1) NOT NULL,
  user_write                   NUMERIC(1) NOT NULL,
  group_read                   NUMERIC(1) NOT NULL,
  group_write                  NUMERIC(1) NOT NULL,
  other_read                   NUMERIC(1) NOT NULL,
  other_write                  NUMERIC(1) NOT NULL,
  row_user_id                  NUMERIC(12) NOT NULL,
  row_group_id                 NUMERIC(3) NOT NULL,
  row_project_id               NUMERIC(4) NOT NULL,
  row_alg_invocation_id        NUMERIC(12) NOT NULL,
  FOREIGN KEY (study_id) REFERENCES EDA.study (study_id),
  PRIMARY KEY (study_characteristic_id)
);

CREATE SEQUENCE EDA.StudyCharacteristic_sq;

CREATE INDEX StudyCharacteristic_ix_1 ON EDA.StudyCharacteristic (study_id, attribute_id, value) ;

-- for mega study, we need to prefix the stable id with the study stable id (bfv=big fat view)
create or replace view EDA.entityattributes_bfv as
select ea.entity_attributes_id
     ,  case when ec.entity_type_id = ea.entity_type_id
            then ea.stable_id
            else s2.stable_id || '|' || ea.stable_id
        end as stable_id
     , ea.entity_type_id as orig_entity_type_id
     , ea.atts
     , ea.row_project_id
     , et.type_id as entity_type_ontology_term_id
     , ec.entity_type_id
     , s.stable_id as study_stable_id
     , s.INTERNAL_ABBREV as study_internal_abbrev
     , s.study_id as study_id
from EDA.entityclassification ec
   , EDA.entityattributes ea
   , EDA.entitytype et
   , EDA.study s
   , EDA.entitytype et2
   , EDA.study s2
 where ec.entity_attributes_id = ea.entity_attributes_id
and ec.entity_type_id = et.entity_type_id
and et.study_id = s.study_id
and ea.ENTITY_TYPE_ID = et2.entity_type_id
and et2.study_id = s2.study_id;

CREATE TABLE EDA.AnnotationProperties (
  annotation_properties_id   NUMERIC(10) NOT NULL,
  ontology_term_id       NUMERIC(10) NOT NULL,
  study_id            NUMERIC(12) NOT NULL,
  props                         TEXT,
 external_database_release_id numeric(10) NOT NULL,
MODIFICATION_DATE     TIMESTAMP,
  USER_READ             NUMERIC(1),
  USER_WRITE            NUMERIC(1),
  GROUP_READ            NUMERIC(1),
  GROUP_WRITE           NUMERIC(1),
  OTHER_READ            NUMERIC(1),
  OTHER_WRITE           NUMERIC(1),
  ROW_USER_ID           NUMERIC(12),
  ROW_GROUP_ID          NUMERIC(3),
  ROW_PROJECT_ID        NUMERIC(4),
  ROW_ALG_INVOCATION_ID NUMERIC(12),
PRIMARY KEY (annotation_properties_id) --,
--  CONSTRAINT ensure_anp_json CHECK (props is json)
);

CREATE SEQUENCE EDA.AnnotationProperties_sq;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA EDA TO vdi_control_dev_n;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA EDA TO vdi_datasets_dev_n;