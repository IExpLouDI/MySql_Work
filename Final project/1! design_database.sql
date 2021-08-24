/*
 * База данных "Приют для животных"
 * База данных состоит из 10 таблиц.
 * Ветвление начинается с таблицы 'City'.
 * В каждом городе расположен свой приют (таблица Shelters), в котором находятся 
 * питомцы (таблица Animals). У каждого питомца есть своё портфолио (таблица animal_profile),
 * в котором указаны: дата рождения, описание малыша и указана ссылка на породу (таблица breeds).
 * Таблица с пользователями (users). У каждого пользователя есть своя анкета (user_profile), в 
 * которой он указывает, помимо обще информации, свой статус (user_status) в зависимости от
 * преследуемой им цели.
 * Пользователи и приюты связаны городом (таблица city). 
 * База данных позволяет людям найти "лучшего друга" в городе, в котором они проживают.
 * 
 */

DROP DATABASE IF EXISTS shelters;

CREATE DATABASE shelters;

USE shelters;

DROP TABLE IF EXISTS city;
CREATE TABLE city (
	id SERIAL PRIMARY KEY,
	name CHAR(50)
);

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(145) NOT NULL,
	last_name VARCHAR(145) NOT NULL,
	email VARCHAR(145) NOT NULL UNIQUE,
	phone CHAR(11) NOT NULL,
	city_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (city_id) REFERENCES city (id)
);

DROP TABLE IF EXISTS user_status;
CREATE TABLE user_status (
	id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
	status ENUM('Сотрудник', 'Ищет друга', 'Счастливый человек')
);

DROP TABLE IF EXISTS user_profile;
CREATE TABLE user_profile (
	user_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	gender ENUM('Female', 'Male') NOT NULL,
	birthday DATE NOT NULL,
	user_status TINYINT UNSIGNED NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users (id),
	FOREIGN KEY (user_status) REFERENCES user_status (id)
);

DROP TABLE IF EXISTS user_photo;
CREATE TABLE user_photo (
	id SERIAL,
	user_id BIGINT UNSIGNED NOT NULL,
	file_name CHAR(40),
	FOREIGN KEY (user_id) REFERENCES users (id)
);

DROP TABLE IF EXISTS shelters;
CREATE TABLE shelters (
	id SERIAL PRIMARY KEY,
	name CHAR(40),
	city_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (city_id) REFERENCES city (id)
);

DROP TABLE IF EXISTS animals;
CREATE TABLE animals (
	id SERIAL PRIMARY KEY,
	name CHAR(40),
	gender ENUM('Male', 'Female') NOT NULL,
	shelter_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (shelter_id) REFERENCES shelters (id)
);

DROP TABLE IF EXISTS breeds;
CREATE TABLE breeds (
	id SERIAL PRIMARY KEY,
	name CHAR(40),
	description TEXT
);

DROP TABLE IF EXISTS animal_profile;
CREATE TABLE animal_profile (
	animal_id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
	birthday DATE NOT NULL,
	txt TEXT,
	breed_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (animal_id) REFERENCES animals (id),
	FOREIGN KEY (breed_id) REFERENCES breeds (id)
);

DROP TABLE IF EXISTS animal_photo;
CREATE TABLE animal_photo (
	id SERIAL PRIMARY KEY,
	animal_id BIGINT UNSIGNED NOT NULL,
	file_name CHAR(40),
	FOREIGN KEY (animal_id) REFERENCES animals (id)
);
