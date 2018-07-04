SELECT 
    a.actor_id
FROM
    actor a,
    role r,
    movie m,
    movie_has_genre mhg,
    genre g
WHERE
    a.actor_id = r.actor_id
        AND r.movie_id = m.movie_id
        AND m.movie_id = mhg.movie_id
        AND mhg.genre_id = g.genre_id
GROUP BY a.actor_id
HAVING count(distinct g.genre_id)=(SELECT count(genre_id)
FROM genre);