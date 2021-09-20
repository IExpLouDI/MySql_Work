
USE shelters;

-- список польователей в зависимости от города пребывания и название приюта в городе

SELECT 
	CONCAT(u.first_name, ' ', u.last_name) AS Customers,
	c.name AS City, 
	s.name AS Shelter 
FROM users u
	JOIN city c ON c.id = u.city_id
	JOIN shelters s ON s.city_id = u.city_id;

-- пользователи приюта, которые являются сотрудниками

SELECT 
	CONCAT(u.first_name, ' ', u.last_name) AS Staff,
	s.name AS Shelter
FROM users u 
	JOIN shelters s ON u.city_id = s.city_id
	JOIN user_profile up ON up.user_id = u.id
WHERE up.user_status = (SELECT id FROM user_status us WHERE us.status = 'Сотрудник')
ORDER BY shelter, staff;

-- пользователи приюта, которые ищут друга

SELECT 
	CONCAT(u.first_name, ' ', u.last_name) AS Staff,
	s.name AS Shelter
FROM users u
JOIN shelters s ON u.city_id = s.city_id
JOIN user_profile up ON up.user_id = u.id
WHERE up.user_status = (SELECT id FROM user_status us WHERE us.status = 'Ищет друга')
ORDER BY Shelter, staff;

-- количество питомцев в зависимости от приюта

SELECT 
	s.name AS Shelter,
	b.name AS Type_animal,
	COUNT(*) AS Animal_count
FROM animals a
	JOIN animal_profile ap ON a.id = ap.animal_id
	JOIN breeds b ON ap.breed_id = b.id
	JOIN shelters s ON a.shelter_id = s.id
GROUP BY s.name, b.name 
ORDER BY s.name, type_animal;

-- вывод возраста питомцев в приюте №2

SELECT 
	a.name, 
	b.name AS Type_animal,
	TIMESTAMPDIFF(YEAR, birthday, now()) AS Age
FROM animal_profile ap 
	JOIN animals a ON ap.animal_id = a.id
	JOIN breeds b ON b.id = ap.breed_id 
WHERE a.shelter_id = 2;

-- предложение пользователю, который ищет друга, питомца из приюта того же города user_id = 3

SELECT 
	id,
	CONCAT(u.first_name, ' ', u.last_name) AS Customers
FROM users u
	JOIN user_profile up ON u.id = up.user_id
WHERE up.user_status = (SELECT id FROM user_status us WHERE status = 'Ищет друга');



-- после регистрации пользователя с статусом "Ищет друга" ему предлагаются животные из приюта его города

SELECT 
	a.name, 
	b.name, 
	TIMESTAMPDIFF(YEAR, ap.birthday, NOW()) AS Age 
FROM animals a
	JOIN shelters s ON a.shelter_id = s.id
	JOIN animal_profile ap ON a.id = ap.animal_id
	JOIN breeds b ON ap.breed_id = b.id 
WHERE s.city_id = (SELECT u.city_id FROM users u WHERE u.id = 3);

-- процедура, которая предлагают пользователю посмотреть питомцев в приюте, расположенном в том же городе

DROP PROCEDURE IF EXISTS recom_anim;

DELIMITER //
CREATE PROCEDURE recom_anim (IN value INT)
BEGIN 
	SELECT 
		a.name AS Name, 
		b.name AS Breed, 
		TIMESTAMPDIFF(YEAR, ap.birthday, NOW()) AS Age 
	FROM animals a
		JOIN shelters s ON a.shelter_id = s.id
		JOIN animal_profile ap ON a.id = ap.animal_id
		JOIN breeds b ON ap.breed_id = b.id 
	WHERE s.city_id = (SELECT u.city_id FROM users u WHERE u.id = value); 
END
DELIMITER ;

-- Тригер, автоматически запускает процедуру с рекомендацией питомцев
-- после того как добавится описание профиля в таблице user_profile
-- и если статус пользователя "Ищет друга"

DROP TRIGGER IF EXISTS user_add;

DELIMITER //
CREATE TRIGGER user_add AFTER INSERT ON user_profile
FOR EACH ROW
BEGIN 
	DECLARE user_status TINYINT;
	DECLARE user_id TINYINT;

	SELECT up.user_status 
	INTO user_status 
	FROM users u 
		JOIN user_profile up ON u.id = up.user_id 
	ORDER BY u.id DESC LIMIT 1;

	SELECT u.id 
	INTO user_id 
	FROM users u 
	ORDER BY id 
	DESC LIMIT 1;
	
	IF user_status = 2 THEN 
		CALL recom_anim(user_id);
	END IF;
END
DELIMITER ;

-- тригер контроля вводимого возраста

DROP TRIGGER IF EXISTS check_birthday_before_insert;

DELIMITER //

CREATE TRIGGER check_birthday_before_insert BEFORE INSERT ON user_profile
FOR EACH ROW
	BEGIN
		IF NEW.birthday >= current_date() THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insert Canceled. Birthday must be in the past!';
		END IF;
	END //
	
DELIMITER ;

DROP TRIGGER IF EXISTS check_birthday_before_update;
DELIMITER //

CREATE TRIGGER check_birthday_before_update BEFORE UPDATE ON user_profile
FOR EACH ROW
BEGIN 
	IF NEW.birthday >= CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Update Canceled. Birthday must be in the past!';
    END IF;
END //

DELIMITER ;

-- представление, которое показывает приюты, какие питомцы в них и количество

DROP VIEW IF EXISTS pets_in_shelter;
CREATE VIEW pets_in_shelter AS 
	SELECT 
		s.name AS Shelter, 
		b.name AS Breed, 
		COUNT(b.name) AS Count
	FROM shelters s 
		JOIN animals a ON a.shelter_id = s.id
		JOIN animal_profile ap ON ap.animal_id = a.id
		JOIN breeds b  ON b.id = ap.breed_id
	GROUP BY Shelter, Breed
	ORDER BY Shelter;


-- представление, которое показывает список сотрудников в каждом приюте и их возраст
DROP VIEW IF EXISTS shelter_staff;

CREATE VIEW shelter_staff AS 
	SELECT 
		s.name AS Shelter,
		c.name AS City,
		CONCAT(u.first_name, ' ', u.last_name) AS shelter_staff,
		TIMESTAMPDIFF(YEAR, up.birthday, NOW()) AS Age,
		u.email AS Email,
		u.phone AS Phone_number
	FROM users u
		JOIN city c ON u.city_id = c.id
		JOIN shelters s ON s.city_id = c.id
		JOIN user_profile up ON up.user_id = u.id
	WHERE up.user_status = (SELECT id FROM user_status us WHERE status = 'Сотрудник')
	ORDER BY Shelter;

-- среднее значение возраста пользователей в каждом городе, которые ищут питомца и у которых есть питомец

SELECT
	c.name AS City,
	us.status AS Status,
	Round(AVG(TIMESTAMPDIFF(YEAR, up.birthday, now())), 1) AS AVG_Age
FROM user_profile up
	JOIN users u ON up.user_id = u.id
	JOIN city c ON u.city_id = c.id
	JOIN user_status us ON up.user_status = us.id 
WHERE us.status != 'Сотрудник'
GROUP BY City, Status
ORDER BY City;

-- количество фотографий у каждого животного в приюте

SELECT 
	a.name AS Name,
	b.name AS Breed,
	s.name AS Shelter, 
	TIMESTAMPDIFF(YEAR, ap2.birthday, now()) AS Age,
	COUNT(a.name) AS Count_photo
FROM animal_photo ap
	JOIN animals a ON a.id = ap.animal_id
	JOIN animal_profile ap2 ON ap2.animal_id = a.id
	JOIN breeds b ON b.id = ap2.breed_id
	JOIN shelters s ON a.shelter_id = s.city_id 
GROUP BY Name
ORDER BY Name;