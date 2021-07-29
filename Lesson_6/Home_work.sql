-- Задание 2. Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, 
-- который больше всех общался с нашим пользователем.

SELECT (SELECT first_name FROM users WHERE id = 1) AS user_name,
CONCAT(first_name, ' ', last_name) AS best_friend_user
FROM users
WHERE id = 
(
	SELECT DISTINCT from_user_id 
	FROM messages 
	WHERE from_user_id IN 
	(
	SELECT to_user_id FROM friend_requests WHERE (from_user_id = 1 OR to_user_id = 1) AND request_type = 1
	) 
	AND to_user_id = 1 AND is_delivered = 1
);

/*
 * 3. Подсчитать общее количество лайков, 
 * которые получили 10 самых молодых пользователей.
 */

SELECT
Count(to_user_id) AS likes,
to_user_id AS id,
(SELECT birthday 
FROM profiles WHERE to_user_id = user_id) AS age
FROM user_like
GROUP BY age
ORDER BY age DESC
LIMIT 10;

/* 4.
 * Определить кто больше поставил лайков (всего)
 *  - мужчины или женщины?
  */

SELECT count(from_user_id) AS gender_likes,
(
SELECT gender FROM profiles 
WHERE from_user_id = user_id AND (gender = 'm' OR gender = 'f')
) AS gender 
FROM user_like
WHERE from_user_id IN (
SELECT user_id FROM profiles WHERE gender = 'm' OR gender = 'f'
) 
GROUP BY gender
ORDER BY gender_likes DESC
LIMIT 1;

/* 5
 * Найти 10 пользователей,
 * которые проявляют наименьшую активность 
 * в использовании социальной сети.
*/
-- Итог

SELECT * FROM posts;
SELECT users.id,
(SELECT count(from_user_id) FROM user_like WHERE id = from_user_id) AS likes,
(SELECT count(user_id) FROM media WHERE users.id = user_id) AS media,
(SELECT count(user_id) FROM posts WHERE users.id = user_id) AS posts
FROM users
ORDER BY likes, media, posts
LIMIT 10;