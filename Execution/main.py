import sys

sys.path.append("./")

from Database_Configs.database import Database

db = Database()

print("Connected to database.")

while True:
    print("\n --- ISS ECLSS Fault Detection System ---")
    print(" 1.  View locations")
    print(" 2.  Add location")
    print(" 3.  Delete location")
    print(" 4.  View sensor data for a location")
    print(" 5.  Add sensor reading")
    print(" 6.  Delete sensor reading")
    print(" 7.  View anomalies (all locations)")
    print(" 8.  View anomaly rate per location")
    print(" 9.  View isolation-forest labels for a location")
    print("10.  View RF classifications for a location")
    print("11.  Add RF classification")
    print("12.  View all fault types")
    print("13.  Set active fault for a location")
    print("14.  Exit")

    choice = input("\nChoice: ").strip()

    # ------------------------------------------------------------------
    if choice == "1":
        locations = db.get_all_locations()
        print(f"\n{'ID':<5} {'Location':<20} {'Active Fault'}")
        print("-" * 45)
        for loc in locations:
            fault = loc["current_fault"] or "—"
            print(f"{loc['id']:<5} {loc['location_name']:<20} {fault}")

    # ------------------------------------------------------------------
    elif choice == "2":
        name = input("Location name: ").strip()
        if name:
            new_id = db.add_location(name)
            print(f"Location added with ID {new_id}.")
        else:
            print("Name cannot be empty.")

    # ------------------------------------------------------------------
    elif choice == "3":
        loc_id = input("Location ID to delete: ").strip()
        confirm = input("Are you sure? (y/n): ").strip().lower()
        if confirm == "y":
            affected = db.delete_location(int(loc_id))
            print(f"Deleted {affected} location(s) and all associated data.")

    # ------------------------------------------------------------------
    elif choice == "4":
        loc_id = input("Location ID: ").strip()
        rows = db.get_data_by_location(int(loc_id))
        if not rows:
            print("No data found for that location.")
        else:
            print(f"\n{'ID':<5} {'Timestamp':<22} {'Data'}")
            print("-" * 80)
            for r in rows:
                print(f"{r['id']:<5} {str(r['timestamp']):<22} {r['data']}")

    # ------------------------------------------------------------------
    elif choice == "5":
        loc_id  = input("Location ID: ").strip()
        voltage = input("Voltage: ").strip()
        current = input("Current: ").strip()
        temp    = input("Temp: ").strip()
        label   = input("Label (normal/anomaly): ").strip()

        if label not in ("normal", "anomaly"):
            print("Invalid label — must be 'normal' or 'anomaly'.")
        else:
            data_json = f'{{"voltage": {voltage}, "current": {current}, "temp": {temp}}}'
            new_id = db.ingest_sensor_reading(int(loc_id), data_json, label)
            print(f"Sensor reading inserted with ID {new_id}.")

    # ------------------------------------------------------------------
    elif choice == "6":
        data_id = input("Data row ID to delete: ").strip()
        confirm = input("Are you sure? (y/n): ").strip().lower()
        if confirm == "y":
            affected = db.delete_data_row(int(data_id))
            print(f"Deleted {affected} data row(s) and associated labels / classifications.")

    # ------------------------------------------------------------------
    elif choice == "7":
        rows = db.search_anomalies_by_location()
        if not rows:
            print("No anomalies found.")
        else:
            print(f"\n{'Location':<20} {'Timestamp':<22} {'Classification':<30} {'Conf.'}")
            print("-" * 80)
            for r in rows:
                clf  = r["classification"] or "unclassified"
                conf = f"{float(r['confidence']):.2%}" if r["confidence"] else "—"
                print(f"{r['location_name']:<20} {str(r['timestamp']):<22} {clf:<30} {conf}")

    # ------------------------------------------------------------------
    elif choice == "8":
        rows = db.get_anomaly_rate_per_location()
        if not rows:
            print("No labelled data found.")
        else:
            print(f"\n{'Location':<20} {'Total':<8} {'Anomalies':<12} {'Rate'}")
            print("-" * 50)
            for r in rows:
                print(
                    f"{r['location_name']:<20} {r['total_readings']:<8} "
                    f"{r['anomaly_count']:<12} {r['anomaly_pct']}%"
                )

    # ------------------------------------------------------------------
    elif choice == "9":
        loc_id = input("Location ID: ").strip()
        rows = db.get_labels_by_location(int(loc_id))
        if not rows:
            print("No labels found for that location.")
        else:
            print(f"\n{'Label ID':<10} {'Data Row ID':<14} {'Timestamp':<22} {'Label'}")
            print("-" * 60)
            for r in rows:
                print(
                    f"{r['label_id']:<10} {r['data_row_id']:<14} "
                    f"{str(r['timestamp']):<22} {r['label']}"
                )

    # ------------------------------------------------------------------
    elif choice == "10":
        loc_id = input("Location ID: ").strip()
        rows = db.get_classifications_by_location(int(loc_id))
        if not rows:
            print("No classifications found for that location.")
        else:
            print(f"\n{'Data Row ID':<14} {'Timestamp':<22} {'IF Label':<10} {'Classification':<30} {'Confidence'}")
            print("-" * 85)
            for r in rows:
                conf = f"{float(r['confidence']):.2%}" if r["confidence"] else "—"
                print(
                    f"{r['data_row_id']:<14} {str(r['timestamp']):<22} "
                    f"{r['label']:<10} {str(r['classification']):<30} {conf}"
                )

    # ------------------------------------------------------------------
    elif choice == "11":
        label_id       = input("Isolation-forest label ID: ").strip()
        classification = input("Classification (e.g. co2_buildup): ").strip()
        confidence     = input("Confidence (0.0 – 1.0): ").strip()
        try:
            conf_val = float(confidence)
            if not (0.0 <= conf_val <= 1.0):
                raise ValueError
            new_id = db.add_classification(int(label_id), classification, conf_val)
            print(f"Classification added with ID {new_id}.")
        except ValueError:
            print("Invalid confidence value — must be a decimal between 0.0 and 1.0.")

    # ------------------------------------------------------------------
    elif choice == "12":
        fault_types = db.get_all_fault_types()
        print(f"\n{'ID':<5} {'Fault Name'}")
        print("-" * 40)
        for ft in fault_types:
            print(f"{ft['id']:<5} {ft['fault_name']}")

    # ------------------------------------------------------------------
    elif choice == "13":
        loc_id = input("Location ID: ").strip()
        print("Enter 0 to clear the active fault.")
        fault_id = input("Fault type ID: ").strip()
        fault_id_val = None if fault_id == "0" else int(fault_id)
        db.set_location_fault(int(loc_id), fault_id_val)
        print("Active fault updated.")

    # ------------------------------------------------------------------
    elif choice == "14":
        print("Goodbye.")
        break

    else:
        print("Invalid choice — please enter a number between 1 and 14.")

db.conn.close()