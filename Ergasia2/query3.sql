use movies;


SELECT DISTINCT
    a.last_name
FROM
    actor a,
    role r,
    movie m,
    movie_has_director mhd,
    director d,
    movie_has_genre mhg,
    genre g
WHERE
    a.actor_id = r.actor_id
        AND r.movie_id = m.movie_id
        AND m.movie_id = mhd.movie_id
        AND mhd.director_id = d.director_id
        AND mhg.movie_id = m.movie_id
        AND g.genre_id = mhg.genre_id
        AND a.last_name <> d.last_name
        AND g.genre_id IN (SELECT 
            g2.genre_id
        FROM
            genre g2,
            actor a2,
            role r2,
            movie m2,
            movie_has_director mhd2,
            director d2,
            movie_has_genre mhg2
        WHERE
            a2.actor_id = r2.actor_id
                AND r2.movie_id = m2.movie_id
                AND m2.movie_id = mhd2.movie_id
                AND mhd2.director_id = d2.director_id
                AND mhg2.movie_id = m2.movie_id
                AND g2.genre_id = mhg2.genre_id
                AND d2.last_name = a.last_name
                AND m2.movie_id NOT IN (SELECT DISTINCT
                    m3.movie_id
                FROM
                    actor a3,
                    role r3,
                    movie m3
                WHERE
                    a3.actor_id = r3.actor_id
                        AND r3.movie_id = m3.movie_id
                        AND a3.last_name = a.last_name))
        AND a.last_name IN (SELECT DISTINCT
            a4.last_name
        FROM
            actor a4,
            role r4,
            movie m4,
            movie_has_director mhd4,
            director d4
        WHERE
            a4.actor_id = r4.actor_id
                AND r4.movie_id = m4.movie_id
                AND m4.movie_id = mhd4.movie_id
                AND mhd4.director_id = d4.director_id
                AND a4.last_name = d4.last_name);
