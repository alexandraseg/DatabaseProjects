-- SELECT m.movie_id
-- FROM movie m, movie_has_genre mhg, genre g
-- WHERE m.movie_id=mhg.movie_id and mhg.genre_id=g.genre_id
-- GROUP BY m.movie_id
-- HAVING count(g.genre_id)=1

SELECT 
    g2.genre_id, COUNT(distinct d2.director_id) as plithos
FROM
    movie m2,
    movie_has_genre mhg2,
    genre g2,
    director d2,
    movie_has_director mhd2
WHERE
    m2.movie_id = mhg2.movie_id
        AND d2.director_id = mhd2.director_id
        AND m2.movie_id = mhd2.movie_id
        AND mhg2.genre_id = g2.genre_id
        AND m2.movie_id IN (SELECT 
            m.movie_id
        FROM
            movie m,
            movie_has_genre mhg,
            genre g
        WHERE
            m.movie_id = mhg.movie_id
                AND mhg.genre_id = g.genre_id
        GROUP BY m.movie_id
        HAVING COUNT(g.genre_id) = 1)
GROUP BY g2.genre_id;