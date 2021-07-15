/* 
����������� ����
*/
USE vk;
-- �������������� ������� ������
-- ��������� �����������, ��� ����������� 
-- �� ����� ��������� ��� ���� ������
ALTER TABLE friend_requests
ADD CONSTRAINT sender_not_reciever_check
CHECK (from_user_id != to_user_id);

SELECT * FROM friend_requests;

-- �������� �����������, ��� �����
-- ������ �� ����
-- https://regex101.com

ALTER TABLE users 
ADD CONSTRAINT phone_check
CHECK (REGEXP_LIKE(phone, '^[0-9]{11}$'));

-- ������ foreign_key �� �����
ALTER TABLE profiles
ADD CONSTRAINT fk_profiles_media
FOREIGN KEY (photo_id) REFERENCES media (id);

/*
	C - CREATE = INSERT 
	R - READ = SELECT
	U - UPDATE = UPDATE 
	D - DELETE = DELETE
*/

-- ��������� ������������

INSERT INTO users (id, first_name, last_name, email, phone, password_hash)
VALUES (DEFAULT, 'Jhan', 'Loktev', 'jhan@mail.com', '89277775564', 'jhan');

SELECT  * FROM users;

-- �������� �������� ���� �� �����=��������
INSERT IGNORE INTO users (id, first_name, last_name, email, phone, password_hash)
VALUES (DEFAULT, 'Jhan', 'Loktev', 'jhan@mail.com', '89277775564', 'jhan');

-- �������� ��� default
INSERT INTO users (first_name, last_name, email, phone, password_hash)
VALUES ('Anna-Lucia', 'Cortez', 'cortez@mail.com', '89276675564', 'anna-luc');

SELECT * FROM users;

-- �������� ��� �������� �������
DESCRIBE users;
INSERT users
VALUES (3, 'Jimbo', 'Cocojambo', 'jambo@mail.com', '87565465577', 'ser', DEFAULT, DEFAULT);

INSERT users
VALUES (2, 'Klara', 'Selezneva', 'selez@mail.com', '84465462322', 'rfe', DEFAULT, default);

-- �������� ��������� �������������
INSERT INTO users (first_name, last_name, email, phone)
VALUES ('Karat', 'Seleznev', 'k_selez@mail.com', '84465462362'),
('Jack', 'Stavridov', 'stavr@mail.com', '79624486848');


-- �������� ����� set

INSERT INTO users
SET first_name = 'Krenk',
	last_name  = 'Jonson',
	email = 'johnson@mail.com',
	phone = '78945623344';

SHOW CREATE TABLE users;

CREATE DATABASE test_1;
USE test_1;

CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(145) NOT NULL,
  `last_name` varchar(145) NOT NULL,
  `email` varchar(145) NOT NULL,
  `phone` char(11) NOT NULL,
  `password_hash` char(65) DEFAULT NULL,
  `like_count` bigint unsigned DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `phone` (`phone`),
  KEY `email_2` (`email`),
  CONSTRAINT `phone_check` CHECK (regexp_like(`phone`,_utf8mb4'^[0-9]{11}$'))
);

INSERT INTO users (first_name, last_name, email, phone)
VALUES ('Jinga', 'Dritovec', 'drita@mail.com', '77776665544');

USE vk;

INSERT users (first_name, last_name, email, phone)
SELECT first_name, last_name, email, phone FROM test_1.users;



/* SELECT 
*/
-- ����� ��������
SELECT 'Hello';

SELECT 1+3;

-- �������� ��� ���� users

SELECT * FROM users;

-- �������� ����� �������������

SELECT first_name FROM users;

-- �������� ���������� �����

SELECT DISTINCTROW last_name, first_name FROM users;

-- ����� � ��������

SELECT * FROM users WHERE last_name = 'Selezneva';
SELECT * FROM users WHERE id <= 4;
SELECT * FROM users WHERE id BETWEEN 3 AND 6;

SELECT * FROM users WHERE password_hash IS NULL;

SELECT * FROM users WHERE password_hash IS NOT NULL;

-- ������� ������� ������ �������������

SELECT * FROM users LIMIT 4;

-- �������� ������� ��������� ������������� ����� ���������� �� id
-- DESC ���������� �� ��������
-- ASC ���������� �� �����������

SELECT * FROM users ORDER BY id DESC LIMIT 4;

-- �������� 4 ��� ������������ �� �������
-- OFFSET num - ���������� �������-�� �����
-- LIMIT num_1, num_2 - ���������� �������-�� � �������� �������-��
SELECT * FROM users ORDER BY id LIMIT 1 OFFSET 3; 
SELECT * FROM users ORDER BY id LIMIT 3,1;

/*
 UPDATE
 */

INSERT INTO messages (from_user_id, to_user_id, txt)
VALUES (1, 2, 'Hi');

INSERT INTO messages (from_user_id, to_user_id, txt)
VALUES (1, 2, 'Fire in the holl');

SELECT * FROM messages;
SELECT * FROM users;

-- �������� ������ ���� ���������

UPDATE messages 
SET is_delivered = TRUE;

-- ������ ����� ���������

UPDATE messages
SET txt = 'Where are you?'
WHERE id = 2;

/*
 * DELETE
	TRUNCATE - ������� ��� ������ �� �������
 * */

DELETE FROM users WHERE last_name = 'Cocojambo';

-- ������� ��� ������ �� �������
DELETE FROM messages;
SELECT * FROM messages;

-- ������� ��� ������ �� messages

TRUNCATE TABLE messages;
-- ������ ��� ��������� ���� ���� ������� �����


