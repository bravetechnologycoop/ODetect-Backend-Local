DO $migration$
    DECLARE migrationId INT;
    DECLARE lastSuccessfulMigrationId INT;
BEGIN
    -- The migration ID of this file
    migrationId := 19;

    -- Get the migration ID of the last file to be successfully run
    SELECT MAX(id) INTO lastSuccessfulMigrationId
    FROM migrations;

    -- Only execute this script if its migration ID is next after the last successful migration ID
    IF migrationId - lastSuccessfulMigrationId = 1 THEN
        -- ADD SCRIPT HERE
        -- Note: To view enum types and their values in `psql`, use the command `\dT+`
        CREATE TYPE alert_type_enum AS ENUM ('BUTTONS_NOT_URGENT', 'BUTTONS_URGENT', 'SENSOR_NO_MOTION', 'SENSOR_DURATION');

        ALTER TABLE sessions
        ADD COLUMN alert_type alert_type_enum;

        UPDATE sessions
        SET alert_type = 'SENSOR_NO_MOTION'
        WHERE alert_reason = 'Stillness';

        UPDATE sessions
        SET alert_type = 'SENSOR_DURATION'
        WHERE alert_reason = 'Duration';

        ALTER TABLE sessions
        DROP COLUMN alert_reason;

        -- Update the migration ID of the last file to be successfully run to the migration ID of this file
        INSERT INTO migrations (id)
        VALUES (migrationId);
    END IF;
END $migration$;