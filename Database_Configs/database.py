import mysql.connector
from mysql.connector import Error


class Database:
    def __init__(self):
        self.conn = self.createConnection()
        cursor = self.conn.cursor()

        self.sqlFromFile("Database_Configs/schema.sql", cursor)
        self.sqlFromFile("Database_Configs/data.sql", cursor)

        self.conn.commit()
        cursor.close()

    def sqlFromFile(self, filename, cursor):
        """Executes MySQL commands derived from a file."""
        with open(filename, "r") as f:
            sql = f.read()

        # Strip single-line comments before splitting on ";"
        lines = [
            line for line in sql.splitlines()
            if not line.strip().startswith("--")
        ]
        cleaned = "\n".join(lines)

        cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        for statement in cleaned.split(";"):
            stmt = statement.strip()
            if stmt:
                cursor.execute(stmt)
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1")

    def createConnection(self):
        """Create and return a database connection."""
        try:
            connection = mysql.connector.connect(
                host="localhost",
                database="hunch_data",
                user="root",
                password="password",
            )
            if connection.is_connected():
                return connection
        except Error as e:
            print(f"Error: {e}")
            return None

    def _cursor(self):
        """Return a dictionary cursor."""
        return self.conn.cursor(dictionary=True)

    # ------------------------------------------------------------------
    # Locations
    # ------------------------------------------------------------------

    def get_all_locations(self):
        """
        Return all locations joined with their active fault name (if any).
        Each row: id, location_name, current_fault_id, current_fault (name or None)
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT l.id,
                   l.location_name,
                   l.current_fault_id,
                   ft.fault_name AS current_fault
            FROM   locations l
            LEFT JOIN fault_types ft ON ft.id = l.current_fault_id
            ORDER BY l.id
            """
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    def add_location(self, name):
        """Insert a new location (no active fault). Returns the new row id."""
        cur = self._cursor()
        cur.execute(
            "INSERT INTO locations (location_name) VALUES (%s)", (name,)
        )
        self.conn.commit()
        new_id = cur.lastrowid
        cur.close()
        return new_id

    def delete_location(self, location_id):
        """
        Delete a location by id.
        """
        cur = self._cursor()
        cur.execute("DELETE FROM locations WHERE id = %s", (location_id,))
        self.conn.commit()
        affected = cur.rowcount
        cur.close()
        return affected

    def set_location_fault(self, location_id, fault_id):
        """
        Update the active fault for a location.
        Pass fault_id=None to clear the fault.
        """
        cur = self._cursor()
        cur.execute(
            "UPDATE locations SET current_fault_id = %s WHERE id = %s",
            (fault_id, location_id),
        )
        self.conn.commit()
        cur.close()

    # ------------------------------------------------------------------
    # Sensor data (generated_data)
    # ------------------------------------------------------------------

    def get_data_by_location(self, location_id):
        """
        Return all sensor readings for a location, newest first.
        Each row: id, location_id, timestamp, data (raw JSON string)
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT id, location_id, timestamp, data
            FROM   generated_data
            WHERE  location_id = %s
            ORDER BY timestamp DESC
            """,
            (location_id,),
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    def ingest_sensor_reading(self, location_id, data_json, label="normal"):
        """
        Insert a sensor reading and its isolation-forest label in one call.
        Returns the new generated_data row id.

        data_json : JSON string, e.g. '{"voltage": 3.3, "current": 0.5, "temp": 24.1}'
        label     : 'normal' or 'anomaly'
        """
        cur = self._cursor()

        cur.execute(
            "INSERT INTO generated_data (location_id, data) VALUES (%s, %s)",
            (location_id, data_json),
        )
        data_row_id = cur.lastrowid

        cur.execute(
            "INSERT INTO isolation_forest_labels (data_row_id, label) VALUES (%s, %s)",
            (data_row_id, label),
        )

        self.conn.commit()
        cur.close()
        return data_row_id

    def delete_data_row(self, data_id):
        """
        Delete a sensor reading by id.
        Cascades to isolation_forest_labels and random_forest_classifications.
        """
        cur = self._cursor()
        cur.execute("DELETE FROM generated_data WHERE id = %s", (data_id,))
        self.conn.commit()
        affected = cur.rowcount
        cur.close()
        return affected

    # ------------------------------------------------------------------
    # Isolation-forest labels
    # ------------------------------------------------------------------

    def get_labels_by_location(self, location_id):
        """
        Return all isolation-forest labels for a location.
        Each row: label_id, data_row_id, timestamp, label
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT ifl.id   AS label_id,
                   gd.id    AS data_row_id,
                   gd.timestamp,
                   ifl.label
            FROM   isolation_forest_labels ifl
            JOIN   generated_data gd ON gd.id = ifl.data_row_id
            WHERE  gd.location_id = %s
            ORDER BY gd.timestamp DESC
            """,
            (location_id,),
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    # ------------------------------------------------------------------
    # Anomaly queries
    # ------------------------------------------------------------------

    def search_anomalies_by_location(self):
        """
        Return every anomalous reading with its location name,
        timestamp, sensor data, and RF classification (if available).
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT l.location_name,
                   gd.timestamp,
                   gd.data,
                   ifl.label,
                   rfc.classification,
                   rfc.confidence
            FROM   isolation_forest_labels ifl
            JOIN   generated_data gd ON gd.id = ifl.data_row_id
            JOIN   locations      l  ON l.id  = gd.location_id
            LEFT JOIN random_forest_classifications rfc ON rfc.label_id = ifl.id
            WHERE  ifl.label = 'anomaly'
            ORDER BY gd.timestamp DESC
            """
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    def get_anomaly_rate_per_location(self):
        """
        Return the anomaly percentage for every location that has
        at least one labelled reading.
        Each row: location_name, total_readings, anomaly_count, anomaly_pct
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT l.location_name,
                   COUNT(ifl.id)                                         AS total_readings,
                   SUM(ifl.label = 'anomaly')                            AS anomaly_count,
                   ROUND(100.0 * SUM(ifl.label = 'anomaly') / COUNT(*), 2) AS anomaly_pct
            FROM   isolation_forest_labels ifl
            JOIN   generated_data gd ON gd.id = ifl.data_row_id
            JOIN   locations      l  ON l.id  = gd.location_id
            GROUP BY l.id, l.location_name
            ORDER BY anomaly_pct DESC
            """
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    # ------------------------------------------------------------------
    # Random-forest classifications
    # ------------------------------------------------------------------

    def get_classifications_by_location(self, location_id):
        """
        Return all RF classifications for a location.
        Each row: data_row_id, timestamp, label, classification, confidence
        """
        cur = self._cursor()
        cur.execute(
            """
            SELECT gd.id        AS data_row_id,
                   gd.timestamp,
                   ifl.label,
                   rfc.classification,
                   rfc.confidence
            FROM   random_forest_classifications rfc
            JOIN   isolation_forest_labels ifl ON ifl.id  = rfc.label_id
            JOIN   generated_data          gd  ON gd.id   = ifl.data_row_id
            WHERE  gd.location_id = %s
            ORDER BY gd.timestamp DESC
            """,
            (location_id,),
        )
        rows = cur.fetchall()
        cur.close()
        return rows

    def add_classification(self, label_id, classification, confidence):
        """
        Insert a random-forest classification result for a given label_id.
        Returns the new row id.
        """
        cur = self._cursor()
        cur.execute(
            """
            INSERT INTO random_forest_classifications
                        (label_id, classification, confidence)
            VALUES (%s, %s, %s)
            """,
            (label_id, classification, confidence),
        )
        self.conn.commit()
        new_id = cur.lastrowid
        cur.close()
        return new_id

    # ------------------------------------------------------------------
    # Fault types
    # ------------------------------------------------------------------

    def get_all_fault_types(self):
        """Return all fault types. Each row: id, fault_name."""
        cur = self._cursor()
        cur.execute("SELECT id, fault_name FROM fault_types ORDER BY id")
        rows = cur.fetchall()
        cur.close()
        return rows