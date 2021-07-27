USE shop;

/*Задание 1.1
 * Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
 Заполните их текущими датой и временем.
 */

UPDATE users 
SET create_at = NOW(),
	update_at = NOW()
WHERE create_at IS NULL AND update_at IS null;

/*Задание 1.2
Таблица users была неудачно спроектирована. 
Записи created_at и updated_at были заданы типом VARCHAR 
и в них долгое время помещались значения в формате 20.10.2017 8:10. 
Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
*/

DROP TABLE IF EXISTS tbl_1;
CREATE TABLE tbl_1(
id SERIAL PRIMARY KEY,
created_at VARCHAR(16) DEFAULT ('20.10.2017 8:10'),
updated_at VARCHAR(16) DEFAULT ('20.10.2017 8:10')
);

INSERT INTO tbl_1 (id) VALUES (1), (2), (3), (4), (5);

CREATE TABLE tbl_2 
SELECT id,
str_to_date(created_at, '%d.%c.%Y %h:%i') AS created_at,
str_to_date(updated_at, '%d.%c.%Y %h:%i') AS updated_at
FROM tbl_1; 

DROP TABLE tbl_1;

CREATE TABLE tbl_1
SELECT id, created_at, updated_at 
FROM tbl_2;

SELECT * FROM tbl_1;

DROP TABLE tbl_2;
DROP TABLE tbl_1;

/* Задание 1.3
 * В таблице складских запасов storehouses_products 
 * в поле value могут встречаться самые разные цифры: 0, 
 * если товар закончился и выше нуля, если на складе имеются запасы. 
 * Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
 * Однако нулевые запасы должны выводиться в конце, после всех записей.
 */

INSERT INTO storehouses_products (value) 
VALUES (1), (2), (100), (2123), (0), (0), (12), (1412);

SELECT 
id, value 
FROM storehouses_products sp 
ORDER BY 
	CASE 
		WHEN value = 0 THEN 1 ELSE 0
	END, value;


/* Задание 2.1
 * Подсчитайте средний возраст пользователей в таблице users
 */

SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) AS middle_year FROM users;

/* Задание 2.2
 * Подсчитайте количество дней рождения, 
 * которые приходятся на каждый из дней недели. 
 * Следует учесть, что необходимы дни недели текущего года, 
 * а не года рождения.
*/

SELECT count(*) AS count_day, 
DATE_FORMAT(birthday_at, '%d') AS birtday_at  
FROM users
GROUP BY birtday_at
ORDER BY count_day;









