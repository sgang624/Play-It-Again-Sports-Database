-- project-assignment-04.sql
-- Section BA: Group 5

-- Suraj Gangaram
-- Anumita Ghosh
-- Varsha Palepu
-- Kevin Baron

-- Q0: the name of the database on the class server in which I can find your schema

-- baronk2_db

-- Under the second `Schemas (1)`
-- Under `public`
-- Mixed in with other tables used throughout the quarter (Attempt was made to
-- isolate the database to its own schema, but pgAdmin's UI was preventative.)

----------------------------------

-- *Q1*: a list of CREATE TABLE statements implementing your schema

CREATE TABLE rental_contact (
	rental_contact_id int PRIMARY KEY,
	last_name varchar(100),
	first_name varchar(100),
	phone_number varchar(20),
	email_address varchar(200),
	drivers_license_no varchar(100),
	street varchar(200),
	city varchar(200),
	state varchar(100),
	zip_code int
);

CREATE TABLE rental_equipment_user (
	rental_equipment_uid int PRIMARY KEY,
	name varchar(200),
	height int,
	weight int,
	age int,
	release_preference VARCHAR(10),
	angle_settings varchar(50),
	direction varchar(50)
);

CREATE TABLE rental (
	rental_id int PRIMARY KEY,
	fk_rental_contact_id int REFERENCES rental_contact(rental_contact_id),
	price money,
	duration_type varchar(20),
	fitting_date date,
	pick_up_date date,
	due_date timestamp,
	user_signature varchar(100),
	user_sign_date date,
	parent_guardian_signature varchar(100),
	parent_guardian_sign_date date,
	pick_up_signature varchar(100),
	pick_up_sign_date date,
	rental_contact_initial varchar(10),
	ski_technician_signature varchar(100),
	assisting_staff_fullname varchar(100)
);

CREATE TABLE rental_equipment (
	rental_serial_number varchar(50) PRIMARY KEY,
	fk_rental_id int REFERENCES rental(rental_id),
	fk_rental_equipment_uid int REFERENCES rental_equipment_user(rental_equipment_uid),
	equipment_type varchar(50),
	equipment_type_serial_number int,
	activation_date date,
	manufacturer varchar(100),
	model varchar(100),
	size varchar(50),
	pricing_status varchar(50),
	deactivation_date date,
	deactivation_initials varchar(10),
	at_offsite boolean,
	notes text,
	ski_binding_type varchar(50),
	wide boolean,
	ski_boot_type varchar(50),
	snowboard_boot_type varchar(50),
	snowboard_binding_color varchar(100)
);

CREATE TABLE authorization_card (
	fk_rental_id int REFERENCES rental(rental_id),
	fk_rental_contact_id int REFERENCES rental_contact(rental_contact_id),
	authorization_amount money,
	name_on_card varchar(100),
	card_number varchar(50),
	expiration varchar(20),
	sec_code int,
	billing_zip_code int,
	customer_signature varchar(100),
	sign_date date,
	PRIMARY KEY (fk_rental_id, fk_rental_contact_id)
);


-----------------------

-- *Q2*: a list of 10 SQL statements using your schema, along with the English
-- question it implements.


-- Q1(1). Has Katie ever rented with Play It Again Sports before?

SELECT r.rental_id, u.rental_equipment_uid, u.name, r.pick_up_date
FROM rental_equipment_user u
JOIN rental_equipment eq ON eq.fk_rental_equipment_uid = u.rental_equipment_uid
JOIN rental r ON eq.fk_rental_id = r.rental_id
WHERE u.name = 'Katie';


-- Q2(2). What card did I use for the authorization for my rental on 2/1/2022
-- under my name (Nabil Ali)?

SELECT card_number
FROM authorization_card
WHERE sign_date = '2022-02-01' AND name_on_card = 'Nabil Ali';

-- Q3(3). What is the price difference between two models of the same size ski (155 cm)?

WITH ski_price_155 AS (
	SELECT r.rental_id, re.size, r.price
	FROM rental_equipment re
	JOIN rental r
	ON re.fk_rental_id = r.rental_id
	WHERE re.equipment_type = 'SK'
		AND re.size = '155'
)
SELECT sp_01.size, sp_01.rental_id, sp_01.price, sp_02.rental_id, sp_02.price
FROM ski_price_155 sp_01, ski_price_155 sp_02
WHERE sp_01.rental_id <> sp_02.rental_id;


-- Q4(4). When was the last time I (Katie) rented with you?

SELECT r.rental_id, u.name, r.pick_up_date
FROM rental_equipment_user u
JOIN rental_equipment re ON u.rental_equipment_uid = re.fk_rental_equipment_uid
JOIN rental r ON r.rental_id = re.fk_rental_id
WHERE u.name = 'Katie'
ORDER BY r.pick_up_date desc;


-- Q6(5). Do you have any upgraded equipment in the same size as the equipment
-- we rented last time (name = John Florendo)?

WITH jf_rentals AS (
	SELECT re.size, r.pick_up_date, re.equipment_type
	FROM rental_equipment_user reu
	JOIN rental_equipment re ON reu.rental_equipment_uid = re.fk_rental_equipment_uid
	JOIN rental r ON re.fk_rental_id = r.rental_id
	WHERE reu.name = 'John Florendo'
), date_of_last_rental AS (
	SELECT max(jf_rentals.pick_up_date)
	FROM jf_rentals
), size_of_last_rental AS (
	SELECT size, equipment_type
	FROM jf_rentals
)
SELECT re.rental_serial_number, re.manufacturer, re.model, re.size, re.pricing_status,
	re.fk_rental_id
FROM rental_equipment re, size_of_last_rental slr
WHERE re.size = slr.size
	AND re.equipment_type = slr.equipment_type
	AND re.pricing_status = 'Upgrade'
	AND re.fk_rental_id IS NULL;


-- Q8(6). Do you currently have a similar-size snowboard to rent out for my
-- twin (manufacturer = ‘Rossignol’, model = ‘EXP’, size = 145)?

SELECT r1.rental_serial_number, r1.fk_rental_id, r1.fk_rental_equipment_uid,
	r1.equipment_type, r1.manufacturer, r1.model, r1.size
FROM rental_equipment r1
WHERE r1.equipment_type = 'SB' AND r1.manufacturer = 'Rossignol' AND r1.model = 'EXP'
	AND r1.size = '145'
	AND r1.fk_rental_id IS NULL
	AND r1.fk_rental_equipment_uid IS NULL;


-- Q9(7). Can I switch from a ski rental to a snowboard rental for the same
-- size (size: 140)?

SELECT count (*) AS num_snowboard
FROM rental_equipment re
WHERE re.fk_rental_id IS NULL AND re.equipment_type = 'SB' AND re.size = '140';


-- Q11(8). How many times has my snowboard (ID: SB0263) I'm renting been rented
-- out already this season?

SELECT count(distinct r.pick_up_date)
FROM rental r, rental_equipment re
WHERE r.rental_id = re.fk_rental_id
AND re.rental_serial_number = 'SB0263';


-- Q12(9). Can I check my release preference for my skis (name: Samuel)?

SELECT release_preference
FROM rental_equipment_user
WHERE name = 'Samuel';


-- Q20(10). How many snowboards do we have all together?

SELECT count(*) AS num_snowboard
FROM rental_equipment
WHERE equipment_type = 'SB'
AND deactivation_date IS NULL;



------------------------------------------

-- *Q3*: a list of 3-5 demo queries that return (minimal) sensible results.
-- These can be a subset of the 10 queries implemented for Q2, in which case
-- it's okay to list them twice.


-- Q2(2). What card did I use for the authorization for my rental on 2/7/2022
-- under my name (Max Word)?

SELECT card_number
FROM authorization_card
WHERE sign_date = '2/1/2022' AND name_on_card = 'Nabil Ali';

-- Results:

"card_number"
"3532556775401812"


-- Q3(3). What is the price difference between two models of the same size ski?

WITH ski_price_155 AS (
	SELECT r.rental_id, re.size, r.price
	FROM rental_equipment re
	JOIN rental r
	ON re.fk_rental_id = r.rental_id
	WHERE re.equipment_type = 'SK'
		AND re.size = '155'
)
SELECT sp_01.size, sp_01.rental_id, sp_01.price, sp_02.rental_id, sp_02.price
FROM ski_price_155 sp_01, ski_price_155 sp_02
WHERE sp_01.rental_id <> sp_02.rental_id;

-- Results:

"size"	"rental_id"	"price"	"rental_id-2"	"price-2"
"155"	746	"$65.00"	344	"$45.00"
"155"	746	"$65.00"	561	"$55.00"
"155"	746	"$65.00"	583	"$130.00"
"155"	746	"$65.00"	130	"$409.98"
"155"	344	"$45.00"	746	"$65.00"
"155"	344	"$45.00"	561	"$55.00"
"155"	344	"$45.00"	583	"$130.00"
"155"	344	"$45.00"	130	"$409.98"
"155"	561	"$55.00"	746	"$65.00"
"155"	561	"$55.00"	344	"$45.00"
"155"	561	"$55.00"	583	"$130.00"
"155"	561	"$55.00"	130	"$409.98"
"155"	583	"$130.00"	746	"$65.00"
"155"	583	"$130.00"	344	"$45.00"
"155"	583	"$130.00"	561	"$55.00"
"155"	583	"$130.00"	130	"$409.98"
"155"	130	"$409.98"	746	"$65.00"
"155"	130	"$409.98"	344	"$45.00"
"155"	130	"$409.98"	561	"$55.00"
"155"	130	"$409.98"	583	"$130.00"


-- Q8(6). Do you currently have a similar-size snowboard to rent out for my
-- twin (manufacturer = ‘Rossignol’, model = ‘EXP’, size = 145)?

SELECT r1.rental_serial_number, r1.fk_rental_id, r1.fk_rental_equipment_uid,
	r1.equipment_type, r1.manufacturer, r1.model, r1.size
FROM rental_equipment r1
WHERE r1.equipment_type = 'SB' AND r1.manufacturer = 'Rossignol' AND r1.model = 'EXP'
	AND r1.size = '145'
	AND r1.fk_rental_id IS NULL
	AND r1.fk_rental_equipment_uid IS NULL;

-- Results:

"rental_serial_number"	"fk_rental_id"	"fk_rental_equipment_uid"	"equipment_type"	"manufacturer"	"model"	"size"
"SB0291"			"SB"	"Rossignol"	"EXP"	"145"
"SB0296"			"SB"	"Rossignol"	"EXP"	"145"
"SB0313"			"SB"	"Rossignol"	"EXP"	"145"


-- Q20(10). How many snowboards do we have all together?

SELECT count(*) AS num_snowboard
FROM rental_equipment
WHERE equipment_type = 'SB'
AND deactivation_date IS NULL;

-- Results:

"num_snowboard"
397
