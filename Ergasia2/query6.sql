-- SELECT 
--     a.actor_id
-- FROM
--     actor a,
--     role r,
--     movie m
-- WHERE
--     a.actor_id = r.actor_id
--         AND r.movie_id = m.movie_id
-- GROUP BY a.actor_id, a.first_name
-- HAVING COUNT(r.movie_id) = 3;

SELECT 
    a2.first_name, a2.last_name,
    COUNT(DISTINCT d2.director_id) AS arithmos_skinothetwn
FROM
    actor a2,
    role r2,
    movie m2,
    movie_has_director mhd2,
    director d2
WHERE
    a2.actor_id = r2.actor_id
        AND r2.movie_id = m2.movie_id
        AND m2.movie_id = mhd2.movie_id
        AND mhd2.director_id = d2.director_id
        AND a2.actor_id IN (SELECT 
            a.actor_id
        FROM
            actor a,
            role r,
            movie m
        WHERE
            a.actor_id = r.actor_id
                AND r.movie_id = m.movie_id
        GROUP BY a.actor_id , a.first_name
        HAVING COUNT(r.movie_id) = 3)
GROUP BY a2.actor_id;
