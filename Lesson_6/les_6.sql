USE vk;

/* ������ 1. �������� �������� ���������� ������������ � id =1
*/

-- �������� ������ ������������ � id 1

SELECT 
	first_name,
	last_name,
	'city',
	'profile_photo'
FROM users
WHERE id = 1;

-- ������� �����

SELECT city FROM profiles WHERE user_id = 1;

-- �������� ������ � ��������
SELECT 
	first_name,
	last_name,
	(SELECT city FROM profiles WHERE user_id = 1),
	'profile_photo'
FROM users
WHERE id = 1;

-- ������� ���� ����������

SELECT photo_id FROM profiles WHERE user_id = 1;

-- ������� ��� ����� � id ����������

SELECT file_name FROM media WHERE id = 1;

-- ������ �� id ������������

SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = 1);

-- ���������� �������
SELECT 
	first_name,
	last_name,
	(SELECT city FROM profiles WHERE user_id = 1) AS City,
	(SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = 1)) AS photo_id
FROM users
WHERE id = 1;

-- ��������������� ������

SELECT 
	first_name,
	last_name,
	(SELECT city FROM profiles WHERE user_id = users.id) AS city,
	(SELECT file_name FROM media WHERE id = (SELECT photo_id FROM profiles WHERE user_id = users.id)) AS photo_id
FROM users
WHERE id = 1;

/*
 * ������� 2. ����� ����������� �����������
 */

-- ���� ��� �������� ������������

SELECT file_name
FROM media
WHERE user_id = 1 AND media_types_id = 1;

-- ���� ����� id ���� ��������

SELECT id FROM media_types WHERE name = 'image';

-- ���������� �������

SELECT file_name
FROM media
WHERE user_id = 1 AND media_types_id = (
									SELECT id FROM media_types WHERE name = 'image');
USE vk;
-- ���� �� ����� id, �� ����� email 'greenfelder.antwan@example.org'

SELECT id FROM users WHERE email = 'greenfelder.antwan@example.org';

-- ���� ����� ������� ������ *.png

SELECT * FROM media WHERE file_name LIKE '%.png';

SELECT file_name 
FROM media
WHERE user_id = 1 AND file_name LIKE '%.png';

-- png and jpg

SELECT file_name 
FROM media
WHERE user_id = 1 AND (file_name LIKE '%.png' OR file_name LIKE '%.jpg');

/* ������� 3. ������� ���������� �����������
*/

-- ���������� ���� ������ � ������� media

SELECT COUNT(*)
FROM media;

-- ������� ���������� �� ������� ����

SELECT COUNT(*), media_types_id
FROM media;



SELECT COUNT(*), media_types_id
FROM media
GROUP BY media_types_id;
SELECT * FROM media;


-- считаем суммарный размер медиафайлов по каждому типу

SELECT SUM(file_size), media_types_id
FROM media
GROUP BY media_types_id;

-- считаем количество медиафайлов по каждому типу с названием типов

SELECT count(*),
		(SELECT name FROM media_types WHERE id = media.media_types_id) AS name
FROM media 
GROUP BY media_types_id;

/* 
ЗАДАНИЕ 4. Посчитаем количество медиафайлов каждого типа для каждого пользователя.
*/

SELECT 
	COUNT(*),
	(SELECT name FROM media_types WHERE id = media.media_types_id) AS name,
	user_id
	FROM media
	GROUP BY media_types_id, user_id
	ORDER BY user_id;
	
/*
Задание 5. Выбираем друзей пользователя с id = 1
*/

-- выбираем кому пользователь отправил заявку

SELECT to_user_id FROM friend_requests WHERE from_user_id = 1;

-- все кто принял заявку

SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 1;

-- выбираем от кого пользователю пришли заявку в друзья

SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1;

-- объединяем две группы, чтобы получисть всех друзей

SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 1
UNION 
SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1;

-- еще вариант без использования UNION

SELECT
	DISTINCT IF(to_user_id = 1, from_user_id, to_user_id) AS friends
FROM friend_requests
WHERE request_type = 1 AND (to_user_id = 1 OR from_user_id = 1);

/* ЗАДАНИЕ 6
-- вывод имен и фамилий друзей пользователся id = 1
*/
-- CONCAT складывает строки

SELECT CONCAT(first_name,' ', last_name) AS name
FROM users
WHERE id IN (2, 3, 5, 7, 11); -- заглушка

-- вариант 
SELECT CONCAT(first_name,' ', last_name) AS name
FROM users
WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 1
		UNION 
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 1);

-- если не знаем, что accepted тип 1

SELECT id FROM friend_requests_types WHERE name = 'accepted';

-- общий вариант

SELECT CONCAT(first_name,' ', last_name) AS name
FROM users
WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 
																		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
														UNION 
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 
																		(SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

-- введем переменную для сохранения результата поиска айди типа дружба accepted

SET @request_state_id := (SELECT id FROM friend_requests_types WHERE name = 'accepted');

SELECT @request_state_id;

-- использование переменной

SELECT CONCAT(first_name,' ', last_name) AS name
FROM users
WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = @request_state_id																		
														UNION 
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = @request_state_id
);

/* Задание 7. Выводим информацию о друзьях. Выводим пол, возраст.
 * 
 */

-- красиво выводим пол

SELECT user_id,
	CASE (gender)
		WHEN 'f' THEN 'female'
		WHEN 'm' THEN 'male'
		WHEN 'x' THEN 'not defined'
	END AS gender
FROM profiles;

-- выводим возраст

SELECT user_id,
	TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
FROM profiles;

-- объединяем 

SELECT user_id,
	CASE (gender)
		WHEN 'f' THEN 'female'
		WHEN 'm' THEN 'male'
		WHEN 'x' THEN 'not defined'
	END AS gender,
	TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
FROM profiles
WHERE user_id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 
														(SELECT id FROM friend_requests_types WHERE name = 'accepted')
														UNION 
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 
														(SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

-- выводим имя и фамилию
SELECT CONCAT(first_name,' ', last_name) AS name,
	(SELECT	CASE (gender)
				WHEN 'f' THEN 'female'
				WHEN 'm' THEN 'male'
				WHEN 'x' THEN 'not defined'
			END	
	FROM profiles
	WHERE user_id = users.id) AS gender,
	(SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) FROM profiles WHERE user_id = users.id) AS age	
FROM users 
WHERE id IN (
	SELECT to_user_id FROM friend_requests WHERE from_user_id = 1 AND  request_type = 
														(SELECT id FROM friend_requests_types WHERE name = 'accepted')
														UNION 
	SELECT from_user_id FROM friend_requests WHERE to_user_id = 1 AND request_type = 
														(SELECT id FROM friend_requests_types WHERE name = 'accepted')
);

/* Задание 8. Выводим все непрочитанные сообщения пользователя с id = 1.
*/

-- выводим все сообщения пользователя, сортируем по дате

SELECT from_user_id, to_user_id, txt, is_delivered, created_at
FROM messages
WHERE from_user_id = 1 OR to_user_id = 1
ORDER BY created_at DESC;

-- выводим все непрочитанные сообщения из диалогов;

SELECT from_user_id, to_user_id, txt, is_delivered, created_at
FROM messages
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = 0
ORDER BY created_at DESC;

-- выводим все непрочитанные сообщения пользователя

SELECT from_user_id, to_user_id, txt, is_delivered, created_at, (from_user_id = 1) AS sorting
FROM messages
WHERE (from_user_id = 1 OR to_user_id = 1) AND is_delivered = 0
ORDER BY (from_user_id = 1) DESC, created_at DESC;
