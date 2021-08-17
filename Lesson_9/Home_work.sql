
-- Задача 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.


DROP DATABASE IF EXISTS sample;
CREATE DATABASE sample;

USE sample;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
id SERIAL PRIMARY KEY,
name VARCHAR(255),
birthday_at DATETIME,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

START TRANSACTION;
INSERT INTO users SELECT * FROM shop.users WHERE id = 1;
COMMIT;
SELECT * FROM users;

/* Задание 2. Создайте представление, 
которое выводит название name товарной позиции из таблицы products
и соответствующее название каталога name из таблицы catalogs.
*/
USE shop;

CREATE VIEW cat(name, catalogs) AS SELECT p.name, cl.name 
FROM products p, catalogs cl
WHERE p.catalog_id = cl.id;
SELECT * FROM cat;



/* ЗАДАНИЕ 3.
 * Создайте хранимую функцию hello(), 
 * которая будет возвращать приветствие,
 *  в зависимости от текущего времени суток. 
 * С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
 * с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
 * с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
 */
-- через процедуру
DROP PROCEDURE IF EXISTS hi;
delimiter //
CREATE PROCEDURE hi ()
BEGIN 
	DECLARE hr int DEFAULT hour(curtime());
	SELECT 
		CASE 
			WHEN 6 <= hr < 12
				THEN 'Доброе утро'
			WHEN 12 <= hr < 18
				THEN 'Добрый день'
			WHEN 18 <= hr <= 23 
				THEN 'Доброй ночи'
			ELSE 'Доброй ночи'
		END AS Say_hi; 
END
delimiter ;
CALL hi ();

-- через функцию
DROP FUNCTION IF EXISTS hello;
DELIMITER //
CREATE FUNCTION hello ()
RETURNS VARCHAR(30) DETERMINISTIC  
BEGIN 
	DECLARE hr int DEFAULT hour(curtime());
	RETURN 
	CASE 
		WHEN 6 <= hr < 12
			THEN 'Доброе утро' 
		WHEN 12 <= hr < 18
			THEN 'Добрый день' 
		WHEN 18 <= hr < 23
			THEN 'Доброй ночи'
		ELSE 'Доброй ночи'
	END;
END
DELIMITER ;

SELECT hello ();

/* ЗАДАНИЕ 4
 * В таблице products есть два текстовых поля: 
 * name с названием товара и 
 * description с его описанием. 
 * Допустимо присутствие обоих полей или одно из них. 
 * Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
 * Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
 * При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/
-- дальше этого варианта, решение не продвинулось. Не понял ошибку)
USE shop;
SELECT * FROM shop.products p;
DROP TRIGGER IF EXISTS check_items;

DELIMITER //

CREATE TRIGGER check_items BEFORE INSERT ON shop.products
FOR EACH ROW BEGIN
	IF COALESCE(NEW.name, NEW.description) IS NULL THEN 
	SIGNAL SQLSTATE '45000';
	END IF; 		
END//
DELIMITER ;




