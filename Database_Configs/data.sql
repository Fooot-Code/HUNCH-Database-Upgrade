-- ============================================================
-- Sample Data — ISS ECLSS Fault Detection System
-- Locations: JLP & JPM, Node 2, Columbus, US Lab,
--            Cupola, Node 1, Joint Airlock
-- Parameters: NASA-STD-3001 / JSC-20584 SMAC limits
-- ============================================================

-- ------------------------------------------------------------
-- fault_types (10 rows)
-- ------------------------------------------------------------
INSERT INTO fault_types (fault_name) VALUES
    ('o2_partial_pressure_deviation'),
    ('co2_buildup'),
    ('humidity_exceedance'),
    ('ogs_output_degradation'),
    ('water_purity_breach'),
    ('cabin_pressure_loss'),
    ('ammonia_leak'),
    ('co_accumulation'),
    ('microbial_bloom'),
    ('airflow_obstruction');

-- ------------------------------------------------------------
-- locations (7 rows — one per ISS module)
-- Some modules have an active injected fault, others are nominal
-- ------------------------------------------------------------
INSERT INTO locations (location_name, current_fault_id) VALUES
    ('JLP & JPM',    NULL),   -- 1  nominal
    ('Node 2',       2),      -- 2  CO2 buildup active
    ('Columbus',     NULL),   -- 3  nominal
    ('US Lab',       7),      -- 4  ammonia leak active
    ('Cupola',       NULL),   -- 5  nominal
    ('Node 1',       6),      -- 6  cabin pressure loss active
    ('Joint Airlock',NULL);   -- 7  nominal

-- ------------------------------------------------------------
-- generated_data (14 rows)
-- data column stores a JSON object of sensor readings.
-- Values are within physical limits; anomalous rows drift
-- outside the nominal operating range.
-- ------------------------------------------------------------
INSERT INTO generated_data (location_id, data, timestamp) VALUES
-- JLP & JPM — nominal
(1, '{"O2 partial pressure":20.9,"CO2 partial pressure":0.38,"Humidity":0.52,"Temperature":22.1,"Cabin pressure":14.7,"Airflow rate":0.45,"CO":2.1,"NH3":0.1,"N2":0.78,"O2":20.9,"CO2":0.38,"CH4":3.2,"H2 (ppm)":4.1,"H2O":0.41,"H2 (%)":0.02,"Bacterial/fungal count":12.0,"O2 output rate (generator)":5.4,"O2 purity (generator)":0.997,"Water purity":1.2,"Production rate (water recovery system)":32.5}', '2024-03-01 06:00:00'),

-- Node 2 — CO2 building up (anomalous)
(2, '{"O2 partial pressure":20.4,"CO2 partial pressure":0.83,"Humidity":0.58,"Temperature":23.5,"Cabin pressure":14.6,"Airflow rate":0.38,"CO":3.8,"NH3":0.2,"N2":0.77,"O2":20.4,"CO2":0.83,"CH4":4.1,"H2 (ppm)":5.0,"H2O":0.45,"H2 (%)":0.01,"Bacterial/fungal count":18.0,"O2 output rate (generator)":5.2,"O2 purity (generator)":0.995,"Water purity":1.5,"Production rate (water recovery system)":31.8}', '2024-03-01 06:05:00'),

-- Columbus — nominal
(3, '{"O2 partial pressure":21.1,"CO2 partial pressure":0.42,"Humidity":0.47,"Temperature":21.8,"Cabin pressure":14.7,"Airflow rate":0.52,"CO":1.9,"NH3":0.0,"N2":0.78,"O2":21.1,"CO2":0.42,"CH4":2.8,"H2 (ppm)":3.7,"H2O":0.39,"H2 (%)":0.01,"Bacterial/fungal count":8.0,"O2 output rate (generator)":5.5,"O2 purity (generator)":0.998,"Water purity":0.9,"Production rate (water recovery system)":33.1}', '2024-03-01 06:10:00'),

-- US Lab — ammonia trace detected (anomalous)
(4, '{"O2 partial pressure":20.7,"CO2 partial pressure":0.45,"Humidity":0.55,"Temperature":22.4,"Cabin pressure":14.7,"Airflow rate":0.41,"CO":2.5,"NH3":12.4,"N2":0.78,"O2":20.7,"CO2":0.45,"CH4":3.5,"H2 (ppm)":4.8,"H2O":0.43,"H2 (%)":0.02,"Bacterial/fungal count":15.0,"O2 output rate (generator)":5.3,"O2 purity (generator)":0.996,"Water purity":1.1,"Production rate (water recovery system)":32.0}', '2024-03-01 06:15:00'),

-- Cupola — nominal
(5, '{"O2 partial pressure":21.0,"CO2 partial pressure":0.35,"Humidity":0.44,"Temperature":20.9,"Cabin pressure":14.7,"Airflow rate":0.60,"CO":1.7,"NH3":0.1,"N2":0.79,"O2":21.0,"CO2":0.35,"CH4":2.5,"H2 (ppm)":3.2,"H2O":0.37,"H2 (%)":0.01,"Bacterial/fungal count":6.0,"O2 output rate (generator)":5.6,"O2 purity (generator)":0.999,"Water purity":0.8,"Production rate (water recovery system)":33.8}', '2024-03-01 06:20:00'),

-- Node 1 — pressure dropping (anomalous)
(6, '{"O2 partial pressure":20.1,"CO2 partial pressure":0.40,"Humidity":0.50,"Temperature":21.5,"Cabin pressure":13.5,"Airflow rate":0.35,"CO":2.2,"NH3":0.1,"N2":0.78,"O2":20.1,"CO2":0.40,"CH4":3.0,"H2 (ppm)":4.0,"H2O":0.40,"H2 (%)":0.02,"Bacterial/fungal count":10.0,"O2 output rate (generator)":4.9,"O2 purity (generator)":0.994,"Water purity":1.3,"Production rate (water recovery system)":31.2}', '2024-03-01 06:25:00'),

-- Joint Airlock — nominal
(7, '{"O2 partial pressure":20.8,"CO2 partial pressure":0.36,"Humidity":0.48,"Temperature":22.0,"Cabin pressure":14.7,"Airflow rate":0.55,"CO":2.0,"NH3":0.0,"N2":0.78,"O2":20.8,"CO2":0.36,"CH4":2.9,"H2 (ppm)":3.9,"H2O":0.41,"H2 (%)":0.01,"Bacterial/fungal count":9.0,"O2 output rate (generator)":5.4,"O2 purity (generator)":0.997,"Water purity":1.0,"Production rate (water recovery system)":32.7}', '2024-03-01 06:30:00'),

-- Second pass — 30 minutes later
-- Node 2 — CO2 worsening
(2, '{"O2 partial pressure":20.1,"CO2 partial pressure":1.21,"Humidity":0.61,"Temperature":24.2,"Cabin pressure":14.6,"Airflow rate":0.33,"CO":4.2,"NH3":0.2,"N2":0.77,"O2":20.1,"CO2":1.21,"CH4":4.5,"H2 (ppm)":5.3,"H2O":0.47,"H2 (%)":0.01,"Bacterial/fungal count":20.0,"O2 output rate (generator)":5.0,"O2 purity (generator)":0.993,"Water purity":1.6,"Production rate (water recovery system)":30.5}', '2024-03-01 06:35:00'),

-- US Lab — NH3 still elevated
(4, '{"O2 partial pressure":20.6,"CO2 partial pressure":0.46,"Humidity":0.56,"Temperature":22.6,"Cabin pressure":14.6,"Airflow rate":0.39,"CO":2.7,"NH3":18.9,"N2":0.78,"O2":20.6,"CO2":0.46,"CH4":3.6,"H2 (ppm)":5.0,"H2O":0.44,"H2 (%)":0.02,"Bacterial/fungal count":17.0,"O2 output rate (generator)":5.2,"O2 purity (generator)":0.995,"Water purity":1.2,"Production rate (water recovery system)":31.6}', '2024-03-01 06:40:00'),

-- Node 1 — pressure still low
(6, '{"O2 partial pressure":19.8,"CO2 partial pressure":0.41,"Humidity":0.51,"Temperature":21.2,"Cabin pressure":13.1,"Airflow rate":0.30,"CO":2.4,"NH3":0.1,"N2":0.77,"O2":19.8,"CO2":0.41,"CH4":3.1,"H2 (ppm)":4.1,"H2O":0.40,"H2 (%)":0.02,"Bacterial/fungal count":11.0,"O2 output rate (generator)":4.7,"O2 purity (generator)":0.992,"Water purity":1.4,"Production rate (water recovery system)":30.8}', '2024-03-01 06:45:00'),

-- JLP & JPM — nominal second reading
(1, '{"O2 partial pressure":21.0,"CO2 partial pressure":0.37,"Humidity":0.51,"Temperature":22.0,"Cabin pressure":14.7,"Airflow rate":0.46,"CO":2.0,"NH3":0.1,"N2":0.78,"O2":21.0,"CO2":0.37,"CH4":3.1,"H2 (ppm)":4.0,"H2O":0.41,"H2 (%)":0.01,"Bacterial/fungal count":11.0,"O2 output rate (generator)":5.4,"O2 purity (generator)":0.997,"Water purity":1.1,"Production rate (water recovery system)":32.4}', '2024-03-01 06:50:00'),

-- Columbus — nominal second reading
(3, '{"O2 partial pressure":21.2,"CO2 partial pressure":0.41,"Humidity":0.46,"Temperature":21.7,"Cabin pressure":14.7,"Airflow rate":0.53,"CO":1.8,"NH3":0.0,"N2":0.79,"O2":21.2,"CO2":0.41,"CH4":2.7,"H2 (ppm)":3.6,"H2O":0.38,"H2 (%)":0.01,"Bacterial/fungal count":7.0,"O2 output rate (generator)":5.5,"O2 purity (generator)":0.998,"Water purity":0.9,"Production rate (water recovery system)":33.3}', '2024-03-01 06:55:00'),

-- Cupola — nominal second reading
(5, '{"O2 partial pressure":21.1,"CO2 partial pressure":0.34,"Humidity":0.43,"Temperature":20.8,"Cabin pressure":14.7,"Airflow rate":0.61,"CO":1.6,"NH3":0.0,"N2":0.79,"O2":21.1,"CO2":0.34,"CH4":2.4,"H2 (ppm)":3.1,"H2O":0.36,"H2 (%)":0.01,"Bacterial/fungal count":5.0,"O2 output rate (generator)":5.6,"O2 purity (generator)":0.999,"Water purity":0.8,"Production rate (water recovery system)":34.0}', '2024-03-01 07:00:00'),

-- Joint Airlock — nominal second reading
(7, '{"O2 partial pressure":20.9,"CO2 partial pressure":0.35,"Humidity":0.47,"Temperature":21.9,"Cabin pressure":14.7,"Airflow rate":0.56,"CO":1.9,"NH3":0.0,"N2":0.78,"O2":20.9,"CO2":0.35,"CH4":2.8,"H2 (ppm)":3.8,"H2O":0.40,"H2 (%)":0.01,"Bacterial/fungal count":8.0,"O2 output rate (generator)":5.3,"O2 purity (generator)":0.997,"Water purity":1.0,"Production rate (water recovery system)":32.9}', '2024-03-01 07:05:00');

-- ------------------------------------------------------------
-- isolation_forest_labels (14 rows — one per generated_data row)
-- Anomalous: Node 2 CO2 (rows 2,8), US Lab NH3 (rows 4,9),
--            Node 1 pressure (rows 6,10)
-- ------------------------------------------------------------
INSERT INTO isolation_forest_labels (data_row_id, label) VALUES
    (1,  'normal'),
    (2,  'anomaly'),
    (3,  'normal'),
    (4,  'anomaly'),
    (5,  'normal'),
    (6,  'anomaly'),
    (7,  'normal'),
    (8,  'anomaly'),
    (9,  'anomaly'),
    (10, 'anomaly'),
    (11, 'normal'),
    (12, 'normal'),
    (13, 'normal'),
    (14, 'normal');

-- ------------------------------------------------------------
-- random_forest_classifications (10 rows)
-- All 6 anomalous rows classified; 4 nominal rows spot-checked
-- ------------------------------------------------------------
INSERT INTO random_forest_classifications (label_id, classification, confidence) VALUES
    (2,  'co2_buildup',           0.9312),
    (4,  'ammonia_leak',          0.9587),
    (6,  'cabin_pressure_loss',   0.9044),
    (8,  'co2_buildup',           0.9671),
    (9,  'ammonia_leak',          0.9423),
    (10, 'cabin_pressure_loss',   0.9208),
    (1,  'normal',                0.9891),
    (3,  'normal',                0.9754),
    (5,  'normal',                0.9830),
    (7,  'normal',                0.9762);