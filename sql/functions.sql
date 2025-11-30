-- create new user
CREATE OR REPLACE FUNCTION create_new_user(
    p_name VARCHAR,
    p_dob DATE,
    p_phone VARCHAR,
    p_email VARCHAR,
    p_address VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    new_user_id INTEGER;
BEGIN
    IF p_name IS NULL OR p_email IS NULL OR p_phone IS NULL THEN
        RAISE EXCEPTION 'Name, Email, and Phone are required fields.';
    END IF;

    INSERT INTO user_main (name, date_of_birth, phone_number, email, address)
    VALUES (p_name, p_dob, p_phone, p_email, p_address)
    RETURNING user_id INTO new_user_id;

    RETURN new_user_id;
END;
$$ LANGUAGE plpgsql;

-- log-in (existed)
CREATE OR REPLACE FUNCTION existed_user(
	p_email VARCHAR
)
RETURNS INTEGER AS $$
DECLARE found_user_id INTEGER;
BEGIN 
	SELECT user_id INTO found_user_id
	FROM user_main WHERE email = p_email; 
    IF found_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication failed. Invalid email or password.';
    END IF;

    RETURN found_user_id;
END;
$$ LANGUAGE plpgsql;


-- add land
CREATE OR REPLACE FUNCTION add_new_land(
    p_user_id INTEGER,
    p_soil_id INTEGER,
    p_land_type VARCHAR,
    p_land_name VARCHAR,
    p_gps_coordinates VARCHAR,
    p_area_size NUMERIC,
    p_geographical_type VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    new_land_id INTEGER;
BEGIN
    IF p_user_id IS NULL OR p_soil_id IS NULL OR p_land_name IS NULL THEN
        RAISE EXCEPTION 'User ID, Soil ID, and Land Name are required to add new land.';
    END IF;

    INSERT INTO Land (
        User_id, Soil_id, land_type, land_name, gps_coordinates, area_size, geographical_type
    )
    VALUES (
        p_user_id, p_soil_id, p_land_type, p_land_name, p_gps_coordinates, p_area_size, p_geographical_type
    )
    RETURNING Land_id INTO new_land_id;

    RETURN new_land_id;
END;
$$ LANGUAGE plpgsql;

-- new planting
CREATE OR REPLACE FUNCTION add_new_planting(
    p_crop_id INTEGER,
    p_fertilizer_id INTEGER,
    p_application_date DATE,
    p_quantity NUMERIC
)
RETURNS INTEGER AS $$
DECLARE
    new_planting_id INTEGER;
BEGIN
    IF p_crop_id IS NULL OR p_fertilizer_id IS NULL OR p_application_date IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Crop ID, Fertilizer ID, Date, and positive Quantity are required.';
    END IF;

    INSERT INTO Planting (
        Crop_id, Fertilizer_id, application_date, quantity
    )
    VALUES (
        p_crop_id, p_fertilizer_id, p_application_date, p_quantity
    )
    RETURNING Planting_id INTO new_planting_id;

    RETURN new_planting_id;
END;
$$ LANGUAGE plpgsql;

-- assign supervisor 
CREATE OR REPLACE FUNCTION assign_supervisor(
    p_user_id INTEGER,
    p_land_id INTEGER,
    p_assigned_date DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER AS $$
DECLARE
    new_supervisor_id INTEGER;
BEGIN
    IF p_user_id IS NULL OR p_land_id IS NULL THEN
        RAISE EXCEPTION 'User ID and Land ID are required for assignment.';
    END IF;

    PERFORM 1 FROM Supervisor WHERE User_id = p_user_id;
    IF FOUND THEN
        RAISE EXCEPTION 'User ID % is already registered as a supervisor. An individual can only hold one supervisor record.', p_user_id;
    END IF;

    INSERT INTO Supervisor (
        User_id, Land_id, assigned_date
    )
    VALUES (
        p_user_id, p_land_id, p_assigned_date
    )
    RETURNING Supervisor_id INTO new_supervisor_id;
    RETURN new_supervisor_id;
END;
$$ LANGUAGE plpgsql;

-- record harvest
CREATE OR REPLACE FUNCTION record_harvest(
    p_crop_id INTEGER,
    p_harvest_date DATE,
    p_quantity_harvest NUMERIC,
    p_total_price NUMERIC
)
RETURNS INTEGER AS $$
DECLARE
    v_planting_date DATE;
    v_land_id INTEGER;
    new_harvest_id INTEGER;
BEGIN
    SELECT planting_date, land_id INTO v_planting_date, v_land_id
    FROM crop
    WHERE crop_id = p_crop_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Crop ID % does not exist.', p_crop_id;
    END IF;

    IF p_harvest_date < v_planting_date THEN
        RAISE EXCEPTION 'Harvest date (%) must be on or after planting date (%) for crop ID %.', p_harvest_date, v_planting_date, p_crop_id;
    END IF;

    INSERT INTO harvest (crop_id, land_id, harvest_date, quantity_harvest, total_price)
    VALUES (p_crop_id, v_land_id, p_harvest_date, p_quantity_harvest, p_total_price)
    RETURNING harvest_id INTO new_harvest_id;
    RETURN new_harvest_id;
END;
$$ LANGUAGE plpgsql;

-- yearly revenue
CREATE OR REPLACE FUNCTION get_user_revenue_by_year(
    p_user_id INTEGER,
    p_year INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    total_revenue NUMERIC := 0;
BEGIN
    SELECT SUM(h.total_price) INTO total_revenue
    FROM harvest h
    JOIN crop c ON h.crop_id = c.crop_id
    JOIN land l ON c.land_id = l.land_id
    WHERE l.user_id = p_user_id
      AND EXTRACT(YEAR FROM h.harvest_date) = p_year;
    RETURN COALESCE(total_revenue, 0);
END;
$$ LANGUAGE plpgsql;

-- view land as whole
CREATE OR REPLACE VIEW view_land_details AS
SELECT
    l.Land_id,
    l.land_name,
    l.area_size AS area_rai,
    l.geographical_type,
    l.gps_coordinates,
    s.soil_name,
    u_owner.name AS owner_name,
    u_owner.email AS owner_email,
    u_supervisor.name AS supervisor_name,
    sup.assigned_date
FROM Land l
JOIN Soil s ON l.Soil_id = s.Soil_id
JOIN user_main u_owner ON l.User_id = u_owner.User_id
LEFT JOIN Supervisor sup ON l.Land_id = sup.Land_id
LEFT JOIN user_main u_supervisor ON sup.User_id = u_supervisor.User_id;


-- view land page
CREATE OR REPLACE FUNCTION user_land_sum(p_user_id INTEGER)
RETURNS TABLE (
    land_name VARCHAR,
    soil_name VARCHAR,
    area_rai NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.land_name,
        s.soil_name,
        l.area_size AS area_rai
    FROM Land l
    JOIN Soil s ON l.Soil_id = s.Soil_id
    WHERE l.User_id = p_user_id;
END;
$$ LANGUAGE plpgsql;


-- view planting based on land page
-- SELECT * FROM crop; 
CREATE OR REPLACE FUNCTION land_planting_page(p_land_id INTEGER)
RETURNS TABLE (
    land_name VARCHAR,
    area_rai NUMERIC,
    soil_name VARCHAR,
    crop_name VARCHAR,
    variety VARCHAR,
    planting_date DATE,
    active_crop_count BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.land_name,
        l.area_size AS area_rai,
        s.soil_name,
        c.crop_name,
        c.variety,
        c.planting_date,
        COUNT(c.crop_id) OVER () AS active_crop_count   -- NEW
    FROM Land l
    JOIN Soil s ON l.Soil_id = s.Soil_id
    LEFT JOIN Crop c
        ON c.Land_id = l.Land_id
        AND c.status IN ('Planted', 'Growing')  
    WHERE l.Land_id = p_land_id;
END;
$$ LANGUAGE plpgsql;


-- profit calculation as a whole
CREATE OR REPLACE VIEW view_crop_profit AS
SELECT
    c.Crop_id,
    c.crop_name,
    c.planting_date,
    l.land_name,
    u.name AS owner_name,
    COALESCE(c.cost, 0) AS seed_cost, -- initial seed/planting cost
    COALESCE(SUM(p.quantity * f.price_per_unit), 0) AS total_fertilizer_cost,
    COALESCE(SUM(h.quantity_harvest), 0) AS total_yield_kg,
    COALESCE(SUM(h.total_price), 0) AS total_revenue,
    (COALESCE(SUM(h.total_price), 0) - (COALESCE(c.cost, 0) + COALESCE(SUM(p.quantity * f.price_per_unit), 0))) AS net_profit_loss
FROM Crop c
JOIN Land l ON c.Land_id = l.Land_id
JOIN user_main u ON l.User_id = u.User_id
LEFT JOIN Planting p ON c.Crop_id = p.Crop_id
LEFT JOIN Fertilizer f ON p.Fertilizer_id = f.Fertilizer_id
LEFT JOIN Harvest h ON c.Crop_id = h.Crop_id
GROUP BY c.Crop_id, l.land_name, u.name; 

-- user profile
CREATE OR REPLACE FUNCTION get_user_profile_analytics(p_user_id INTEGER)
RETURNS TABLE (
    user_name VARCHAR,
    user_email VARCHAR,
    user_phone VARCHAR,
    is_supervisor BOOLEAN,
    total_lands BIGINT,
    total_area_rai NUMERIC,
    crops_planted_count BIGINT,
    supervisor_count BIGINT
)
AS $$
BEGIN
    SELECT
        u.name,
        u.email,
        u.phone_number,
        CASE WHEN s.user_id IS NOT NULL THEN TRUE ELSE FALSE END INTO
        user_name,
        user_email,
        user_phone,
        is_supervisor
    FROM user_main u
    LEFT JOIN supervisor s ON u.user_id = s.user_id
    WHERE u.user_id = p_user_id;

    IF user_name IS NULL THEN
        RAISE EXCEPTION 'User ID % not found.', p_user_id;
    END IF;

    SELECT
        COUNT(l.land_id),
        COALESCE(SUM(l.area_size), 0) INTO
        total_lands,
        total_area_rai
    FROM Land l
    WHERE l.User_id = p_user_id;

    SELECT
        COUNT(c.crop_id) INTO
        crops_planted_count
    FROM Crop c
    JOIN Land l ON c.Land_id = l.Land_id
    WHERE l.User_id = p_user_id;

  
    SELECT
        COUNT(DISTINCT sup.supervisor_id) INTO
        supervisor_count
    FROM Supervisor sup
    JOIN Land l ON sup.Land_id = l.Land_id
    WHERE l.User_id = p_user_id;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- revenue by land 
CREATE OR REPLACE FUNCTION get_land_profit(p_user_id INT)
RETURNS TABLE (
    land_id INT,
    land_name VARCHAR,
    total_seed_cost DECIMAL,
    total_fertilizer_cost DECIMAL,
    total_yield_kg DECIMAL,
    total_revenue DECIMAL,
    average_price_per_kg DECIMAL, 
    net_profit_loss DECIMAL
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.Land_id,
        l.land_name,
        COALESCE(SUM(c.cost), 0) AS total_seed_cost,
        COALESCE(SUM(p.quantity * f.price_per_unit), 0) AS total_fertilizer_cost,
        COALESCE(SUM(h.quantity_harvest), 0) AS total_yield_kg,
        COALESCE(SUM(h.total_price), 0) AS total_revenue,
        CASE
            WHEN COALESCE(SUM(h.quantity_harvest), 0) > 0 
            THEN COALESCE(SUM(h.total_price), 0) / COALESCE(SUM(h.quantity_harvest), 0)
            ELSE 0 
        END AS average_price_per_kg,
        (COALESCE(SUM(h.total_price), 0) - (COALESCE(SUM(c.cost), 0) + COALESCE(SUM(p.quantity * f.price_per_unit), 0))) AS net_profit_loss
    FROM Land l
    JOIN user_main u ON l.User_id = u.User_id
    JOIN Crop c ON l.Land_id = c.Land_id
    
    LEFT JOIN Planting p ON c.Crop_id = p.Crop_id
    LEFT JOIN Fertilizer f ON p.Fertilizer_id = f.Fertilizer_id
    LEFT JOIN Harvest h ON c.Crop_id = h.Crop_id
    
    WHERE u.User_id = p_user_id 
    
    GROUP BY
        l.Land_id,
        l.land_name;
END;
$$ LANGUAGE plpgsql;

-- fertilizer
CREATE OR REPLACE FUNCTION get_land_fertilizer(p_land_id INT)
RETURNS TABLE (
    application_date DATE,
    fertilizer_type VARCHAR,
    quantity_applied DECIMAL,
    unit_cost DECIMAL,
    total_cost DECIMAL
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.application_date AS application_date,
        f.fertilizer_name AS fertilizer_type, 
        p.quantity AS quantity_applied,
        f.price_per_unit AS unit_cost,
        (p.quantity * f.price_per_unit) AS total_cost
    FROM Land l
    JOIN Crop c ON l.Land_id = c.Land_id
    JOIN Planting p ON c.Crop_id = p.Crop_id
    JOIN Fertilizer f ON p.Fertilizer_id = f.Fertilizer_id
    
    WHERE l.Land_id = p_land_id
    ORDER BY p.application_date;
END;
$$ LANGUAGE plpgsql;