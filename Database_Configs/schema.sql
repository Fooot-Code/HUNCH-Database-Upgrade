CREATE TABLE IF NOT EXISTS fault_types (
    id         INT          NOT NULL AUTO_INCREMENT,
    fault_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_fault_name (fault_name),
    CONSTRAINT chk_fault_name_notempty CHECK (CHAR_LENGTH(TRIM(fault_name)) > 0)
);

CREATE TABLE IF NOT EXISTS locations (
    id               INT      NOT NULL AUTO_INCREMENT,
    location_name    TEXT     NOT NULL,
    current_fault_id INT      DEFAULT NULL,
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_locations_fault_type
        FOREIGN KEY (current_fault_id)
        REFERENCES fault_types (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS generated_data (
    id          INT      NOT NULL AUTO_INCREMENT,
    location_id INT      NOT NULL,
    data        TEXT     NOT NULL,
    timestamp   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_generated_data_location
        FOREIGN KEY (location_id)
        REFERENCES locations (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS isolation_forest_labels (
    id          INT         NOT NULL AUTO_INCREMENT,
    data_row_id INT         NOT NULL,
    label       VARCHAR(50) NOT NULL DEFAULT 'normal',
    created_at  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ifl_data_row (data_row_id),
    CONSTRAINT fk_ifl_generated_data
        FOREIGN KEY (data_row_id)
        REFERENCES generated_data (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_ifl_label CHECK (label IN ('normal', 'anomaly'))
);

CREATE TABLE IF NOT EXISTS random_forest_classifications (
    id             INT          NOT NULL AUTO_INCREMENT,
    label_id       INT          NOT NULL,
    classification TEXT         DEFAULT NULL,
    confidence     DECIMAL(5,4) DEFAULT NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_rfc_label (label_id),
    CONSTRAINT fk_rfc_isolation_label
        FOREIGN KEY (label_id)
        REFERENCES isolation_forest_labels (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_rfc_confidence
        CHECK (confidence IS NULL OR (confidence >= 0.0 AND confidence <= 1.0))
);