-- Active: 1763712579835@@dpg-d4g1f3u3jp1c73dbior0-a.singapore-postgres.render.com@5432@anjoedog_irzd

CREATE TABLE Fertilizer (
    Fertilizer_id SERIAL PRIMARY KEY,
    fertilizer_name VARCHAR(100) NOT NULL,
    fertilizer_type VARCHAR(50),
    price_per_unit NUMERIC(10, 2)
);

CREATE TABLE Soil (
    Soil_id SERIAL PRIMARY KEY,
    soil_name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE User (
    User_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    phone_number VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255)
);


CREATE TABLE Land (
    Land_id SERIAL PRIMARY KEY,
    User_id INTEGER REFERENCES User(User_id), 
    Soil_id INTEGER REFERENCES Soil(Soil_id), 
    land_type VARCHAR(50),
    land_name VARCHAR(100) NOT NULL,
    gps_coordinates VARCHAR(50),
    area_size NUMERIC(10, 2),
    geographical_type VARCHAR(50)
);

CREATE TABLE Supervisor (
    Supervisor_id SERIAL PRIMARY KEY,
    User_id INTEGER REFERENCES User(User_id) UNIQUE, 
    Land_id INTEGER REFERENCES Land(Land_id), 
    assigned_date DATE NOT NULL,
    end_date DATE
);


CREATE TABLE Crop (
    Crop_id SERIAL PRIMARY KEY,
    Land_id INTEGER REFERENCES Land(Land_id), 
    crop_name VARCHAR(100) NOT NULL,
    variety VARCHAR(100),
    planting_date DATE,
    area_planted NUMERIC(10, 2),
    cost NUMERIC(10, 2),
    expected_yield NUMERIC(10, 2),
    status VARCHAR(50)
);

CREATE TABLE Planting (
    Planting_id SERIAL PRIMARY KEY,
    Crop_id INTEGER REFERENCES Crop(Crop_id), 
    Fertilizer_id INTEGER REFERENCES Fertilizer(Fertilizer_id), 
    application_date DATE NOT NULL,
    quantity NUMERIC(10, 2),
    UNIQUE (Crop_id, Fertilizer_id, application_date)
);

CREATE TABLE Harvest (
    Harvest_id SERIAL PRIMARY KEY,
    Crop_id INTEGER REFERENCES Crop(Crop_id), 
    Land_id INTEGER REFERENCES Land(Land_id), 
    harvest_date DATE NOT NULL,
    quantity_harvest NUMERIC(10, 2),
    total_price NUMERIC(10, 2)
);

-- the data that used to populate the table is fabricated 
INTO User_main (name, date_of_birth, phone_number, email, address) VALUES
('Sombat Boonma', '1975-08-12', '081-2345-101', 'sombat.b@mail.com', '12/5 Moo 4, Banglen, Nakhon Pathom'),
('Preeya Thongdee', '1968-04-25', '087-5555-102', 'preeya.t@mail.com', '99 T. Mae Rim, Chiang Mai'),
('Chalee Intasorn', '1990-11-03', '092-2346-103', 'chalee.i@mail.com', '22 Soi 8, Muang, Udon Thani'),
('Malee Wongwan', '1982-01-15', '063-8976-104', 'malee.w@mail.com', '7 Rattanathibet Rd, Nonthaburi'),
('Anuwat Sangpetch', '1955-06-20', '089-9088-105', 'anuwat.s@mail.com', '1 Patong Beach Rd, Phuket'),
('Duangdao Kaewsuwan', '1978-09-10', '061-1234-106', 'duangdao.k@mail.com', '50/1 T. Ban Chang, Rayong'),
('Bancha Limthong', '1995-03-28', '098-4567-107', 'bancha.l@mail.com', '100 Sukhumvit 71, Bangkok'),
('Wuttichai Pratoom', '1960-12-01', '084-5636-108', 'wuttichai.p@mail.com', '33 Moo 12, Hua Hin, Prachuap Khiri Khan'),
('Ladda Srisuwan', '1980-02-02', '086-3455-109', 'ladda.s@mail.com', '15 Tha Phae Rd, Chiang Mai'),
('Ekachai Somboon', '1972-07-07', '099-2346-110', 'ekachai.s@mail.com', '88/8 Kanchanaburi Rd, Kanchanaburi'),
('Jiraporn Kraisorn', '1985-05-18', '085-8636-111', 'jiraporn.k@mail.com', '77/3 T. Khuk Khak, Phang Nga'),
('Teerayut Phoboon', '1993-10-22', '094-3457-112', 'teerayut.p@mail.com', '111 T. Pak Phli, Nakhon Nayok'),
('Siriporn Manee', '1970-04-05', '062-4567-113', 'siriporn.m@mail.com', '23/1 A. Muang, Chonburi'),
('Kasem Nilrat', '1965-09-09', '088-2367-114', 'kasem.n@mail.com', '66/2 T. Ban Mai, Phetchabun'),
('Saichai Dee', '1988-12-24', '083-3457-115', 'saichai.d@mail.com', '40/4 Phetkasem Rd, Trang'),
('Thanida Ploy', '1991-03-10', '065-9563-116', 'thanida.p@mail.com', '5 Sukhumvit Soi 24, Bangkok'),
('Kittisak Chuen', '1977-06-17', '097-2357-117', 'kittisak.c@mail.com', '12 Moo 7, T. Don Yang, Phatthalung'),
('Waranya Faifaa', '1984-08-08', '082-8764-118', 'waranya.f@mail.com', '89 Chaengwattana Rd, Nonthaburi'),
('Pongpat Phum', '1963-02-14', '090-9453-119', 'pongpat.p@mail.com', '45 Banthat Thong Rd, Bangkok'),
('Natthida Somsri', '1996-10-31', '064-2357-120', 'natthida.s@mail.com', '11/1 T. Nong Nae, Saraburi');

INSERT INTO Soil (soil_name, description) VALUES
('Clay Loam (เหนียวปนทราย)', 'Highly fertile, medium drainage, common in Central Plains.'),
('Sandy Soil (ดินทราย)', 'Low fertility, fast drainage, common in Northeast (Isaan) region.'),
('Acid Sulfate Soil (ดินเปรี้ยว)', 'Very acidic, low pH, typical of coastal plains and some rice fields.'),
('Alluvial Soil (ดินตะกอนน้ำพา)', 'Rich, deposited by rivers, excellent for rice and fruit trees.'),
('Lateritic Soil (ดินลูกรัง)', 'Reddish color, poor structure, found on plateaus and used for rubber.');

INSERT INTO Fertilizer (fertilizer_name, fertilizer_type, price_per_unit) VALUES
('16-16-16 Formula', 'NPK Compound', 16.50),
('Urea 46-0-0', 'Nitrogen', 12.00),
('Chemical Fertilizer', 'Organic-Chemical Blend', 10.50),
('Organic Fertilizer', 'Organic Compost', 8.00),
('Potassium Chloride (0-0-60)', 'Potassium', 18.00);

INSERT INTO Land (User_id, Soil_id, land_type, land_name, gps_coordinates, area_size, geographical_type) VALUES
(1, 4, 'Rice Paddy', 'Thung Na Klang', '14.00,100.15', 30.0, 'Central Plain'),
(2, 1, 'Fruit Orchard', 'Suan Lum Yai', '18.78,98.98', 15.0, 'Northern Hill'),
(3, 2, 'Crop Field', 'Rai Man', '17.40,102.80', 45.0, 'Isaan Plateau'),
(4, 3, 'Rice Paddy', 'Thung Na Khao', '13.50,100.40', 20.0, 'Coastal Plain'),
(5, 5, 'Rubber Plantation', 'Suan Yang', '7.90,98.30', 50.0, 'Southern Ridge'),
(6, 4, 'Fruit Orchard', 'Suan Durian', '12.67,101.27', 10.0, 'Eastern Region'),
(7, 2, 'Crop Field', 'Rai Khao Pho', '14.20,100.10', 18.0, 'Central Plain'),
(8, 5, 'Palm Plantation', 'Rai Palm', '12.50,99.90', 60.0, 'Western Coast'),
(9, 1, 'Vegetable Farm', 'Phak Sote', '18.80,98.95', 5.0, 'Northern Valley'),
(10, 4, 'Rice Paddy', 'Thung Na Tai', '14.05,99.50', 25.0, 'Western Border'),
(11, 5, 'Rubber Plantation', 'Suan Yang Songkhla', '8.50,98.40', 35.0, 'Southern Region'),
(12, 2, 'Cassava Field', 'Rai Man San', '14.15,101.00', 40.0, 'Central Upland'),
(13, 1, 'Fruit Orchard', 'Suan Mangkoon', '13.35,101.00', 12.0, 'Eastern Coast'),
(14, 4, 'Rice Paddy', 'Thung Na Nuea', '16.78,100.40', 33.0, 'North Central'),
(15, 3, 'Shrimp Farm Land', 'Baw Kung', '7.50,99.60', 15.0, 'Southern Coastal');

INSERT INTO Supervisor (User_id, Land_id, assigned_date, end_date) VALUES
(7, 1, '2024-01-01', NULL),
(9, 2, '2023-11-15', NULL),
(11, 5, '2023-05-20', '2024-03-31'), 
(13, 6, '2024-04-01', NULL),
(15, 3, '2024-02-10', NULL);

INSERT INTO Crop (Land_id, crop_name, variety, planting_date, area_planted, cost, expected_yield, status) VALUES
(1, 'Rice', 'Jasmine (Hom Mali)', '2024-05-15', 30.0, 45000.00, 18000.00, 'Planted'),
(2, 'Longan', 'Phet Sakhon', '2023-01-01', 15.0, 50000.00, 10000.00, 'Harvested'),
(3, 'Cassava', 'Huay Bong 60', '2024-04-01', 45.0, 67500.00, 225000.00, 'Growing'),
(5, 'Rubber', 'RRIT 251', '2022-10-10', 50.0, 150000.00, 15000.00, 'Growing'),
(6, 'Durian', 'Mon Thong', '2024-01-20', 10.0, 40000.00, 5000.00, 'Growing'),
(7, 'Corn', 'Sweet Corn', '2024-03-05', 18.0, 27000.00, 18000.00, 'Harvested'),
(9, 'Chilli', 'Prik Jinda', '2024-02-15', 5.0, 15000.00, 4000.00, 'Growing'),
(10, 'Rice', 'Phatthalung', '2023-11-01', 25.0, 37500.00, 15000.00, 'Harvested'),
(11, 'Rubber', 'RRIM 600', '2023-06-01', 35.0, 105000.00, 10500.00, 'Growing'),
(13, 'Mangosteen', 'Chumphon', '2024-03-01', 12.0, 48000.00, 6000.00, 'Planted'),
(4, 'Rice', 'Pathum Thani', '2023-05-01', 20.0, 30000.00, 12000.00, 'Harvested'),
(8, 'Oil Palm', 'Dura', '2024-01-10', 60.0, 180000.00, 90000.00, 'Growing'),
(3, 'Sugarcane', 'Kaset 3', '2023-08-20', 20.0, 30000.00, 100000.00, 'Harvested'),
(14, 'Rice', 'Sticky Rice', '2024-04-25', 33.0, 49500.00, 19800.00, 'Planted'),
(7, 'Corn', 'Field Corn', '2023-09-01', 18.0, 27000.00, 21600.00, 'Harvested');

INSERT INTO Planting (Crop_id, Fertilizer_id, application_date, quantity) VALUES
(301, 1, '2024-05-20', 1500.0), -- Rice, NPK 16-16-16
(303, 2, '2024-04-10', 2500.0), -- Cassava, Urea
(305, 4, '2024-02-01', 150.0), -- Durian, Organic Compost
(307, 3, '2024-03-01', 800.0), -- Chilli, Organic-Chemical Blend
(310, 1, '2024-03-10', 1000.0), -- Mangosteen, NPK 16-16-16
(301, 2, '2024-06-01', 1000.0), -- Rice, Urea (Top-dress)
(304, 5, '2024-01-01', 500.0), -- Rubber, Potassium
(303, 1, '2024-05-05', 2000.0), -- Cassava, NPK 16-16-16
(305, 1, '2024-04-01', 500.0), -- Durian, NPK 16-16-16
(312, 1, '2024-01-20', 3000.0), -- Oil Palm, NPK 16-16-16
(309, 5, '2023-12-01', 750.0), -- Rubber, Potassium
(314, 2, '2024-05-05', 1500.0), -- Sticky Rice, Urea
(302, 3, '2023-03-01', 600.0), -- Longan, Organic-Chemical Blend
(310, 4, '2024-05-15', 200.0), -- Mangosteen, Organic Compost
(307, 1, '2024-04-20', 400.0); -- Chilli, NPK 16-16-16

INSERT INTO Harvest (Crop_id, Land_id, harvest_date, quantity_harvest, total_price) VALUES
(2, 2, '2023-08-15', 9500.00, 285000.00), -- Longan (Ladda Srisuwan)
(6, 7, '2024-05-10', 17500.00, 105000.00), -- Sweet Corn (Bancha Limthong)
(8, 10, '2024-03-01', 14500.00, 130500.00), -- Rice (Ekachai Somboon)
(11, 4, '2023-10-01', 11800.00, 94400.00), -- Rice (Malee Wongwan)
(13, 3, '2024-05-20', 98000.00, 490000.00), -- Sugarcane (Chalee Intasorn)
(15, 7, '2023-12-15', 21000.00, 126000.00), -- Field Corn (Bancha Limthong)
(2, 2, '2023-08-16', 500.00, 15000.00), -- Longan (second batch)
(6, 7, '2024-05-11', 200.00, 1200.00),  -- Sweet Corn (small batch)
(8, 10, '2024-03-02', 500.00, 4500.00),  -- Rice (small batch)
(11, 4, '2023-10-02', 200.00, 1600.00),  -- Rice (small batch)
(13, 3, '2024-05-21', 1000.00, 5000.00), -- Sugarcane (final batch)
(15, 7, '2023-12-16', 600.00, 3600.00),  -- Field Corn (final batch)
(2, 2, '2023-08-17', 200.00, 6000.00),  -- Longan (final batch)
(8, 10, '2024-03-03', 100.00, 900.00),  -- Rice (final batch)
(11, 4, '2023-10-03', 50.00, 400.00);   -- Rice (final batch)