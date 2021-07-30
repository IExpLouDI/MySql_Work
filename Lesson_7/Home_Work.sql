USE shop;

/* #1
Составьте список пользователей users,
которые осуществили хотя бы один заказ orders в интернет магазине.
*/

SELECT name,
(SELECT count(user_id) FROM orders WHERE users.id = user_id) AS orders
FROM users
WHERE (SELECT count(user_id) FROM orders WHERE users.id = user_id) > 0
ORDER BY orders DESC;

/*#2
Выведите список товаров products и разделов catalogs,
который соответствует товару.
*/

SELECT products.name, catalogs.name
FROM products, catalogs
WHERE catalogs.id = products.catalog_id;

/*#3
Пусть имеется таблица рейсов flights (id, from, to) 
и таблица городов cities (label, name). 
Поля from, to и label содержат английские названия городов, 
поле name — русское. 
Выведите список рейсов flights с русскими названиями городов.
*/

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
id SERIAL PRIMARY KEY AUTO_INCREMENT,
from_city VARCHAR(30),
to_city VARCHAR(30)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
label VARCHAR(30),
name VARCHAR(30)
);

INSERT INTO flights (from_city, to_city) 
VALUES
('moscow', 'omsk'),
('novgorod', 'kazan'),
('irkutsk', 'moscow'),
('omsk', 'irkutsk'),
('moscow', 'kazan');

INSERT INTO cities (label, name)
VALUES 
('moscow', 'Москва'),
('irkutsk', 'Иркутск'),
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');

SELECT id,
(SELECT name FROM cities WHERE flights.from_city = cities.label) AS from_city,
(SELECT name FROM cities WHERE flights.to_city = cities.label) AS to_city
FROM flights;

