/* Задание 1
Создайте таблицу logs типа Archive. 
Пусть при каждом создании записи в таблицах users, 
catalogs и products в таблицу logs помещается время и дата создания записи, 
название таблицы, идентификатор первичного ключа и содержимое поля name.
*/

USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs(
id SERIAL,
tabl_name CHAR(10),
insert_id INT UNSIGNED NOT NULL,
insert_name VARCHAR(30),
created_at DATETIME DEFAULT NOW()
) ENGINE=ARCHIVE;

DROP TRIGGER IF EXISTS ins_log_users;
DROP TRIGGER IF EXISTS ins_log_catalogs;
DROP TRIGGER IF EXISTS ins_log_products;

DELIMITER //
CREATE TRIGGER ins_log_users AFTER INSERT ON users
FOR EACH ROW 
BEGIN
	INSERT INTO logs(tabl_name, insert_id, insert_name, created_at) 
		SELECT 'users', users.id, users.name, users.updated_at FROM users ORDER BY users.id DESC LIMIT 1;
END
DELIMITER ;

DELIMITER //
CREATE TRIGGER ins_log_catalogs AFTER INSERT ON catalogs
FOR EACH ROW 
BEGIN 
	INSERT INTO logs(tabl_name, insert_id, insert_name)
		SELECT 'catalogs', catalogs.id, catalogs.name FROM catalogs c ORDER BY catalogs.id LIMIT 1;
END
DELIMITER ;

DELIMITER //
CREATE TRIGGER ins_log_products AFTER INSERT ON products
FOR EACH ROW 
BEGIN 
	INSERT INTO logs(tabl_name, insert_id, insert_name)
		SELECT 'products', p.id, p.name, p.updated_at FROM products p ORDER BY p.id DESC LIMIT 1;
END
DELIMITER ;

