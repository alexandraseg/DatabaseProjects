-- SELECT m.movie_id
-- FROM director d, movie_has_director mhd, movie m
-- WHERE d.director_id=mhd.director_id and mhd.movie_id=m.movie_id
-- GROUP BY m.movie_id
-- HAVING count(d.director_id)=2;

SELECT 
    d2.last_name AS skinothetis1, d3.last_name AS skinothetis2
FROM
    director d2,
    director d3
WHERE
    d2.director_id <> d3.director_id
        AND d2.director_id IN (SELECT 
            d1.last_name
        FROM
            director d1,
            movie_has_director mhd1,
            movie m1
        WHERE
            d1.director_id = mhd1.director_id
                AND mhd1.movie_id = m1.movie_id
                AND m1.movie_id IN (SELECT 
                    m.movie_id
                FROM
                    director d,
                    movie_has_director mhd,
                    movie m
                WHERE
                    d.director_id = mhd.director_id
                        AND mhd.movie_id = m.movie_id
                GROUP BY m.movie_id
                HAVING COUNT(d.director_id) = 2
                    AND year >= 2000
                    AND year <= 2006))
        AND d3.director_id IN (SELECT 
            d1.last_name
        FROM
            director d1,
            movie_has_director mhd1,
            movie m1
        WHERE
            d1.director_id = mhd1.director_id
                AND mhd1.movie_id = m1.movie_id
                AND m1.movie_id IN (SELECT 
                    m.movie_id
                FROM
                    director d,
                    movie_has_director mhd,
                    movie m
                WHERE
                    d.director_id = mhd.director_id
                        AND mhd.movie_id = m.movie_id
                GROUP BY m.movie_id
                HAVING COUNT(d.director_id) = 2
                    AND year >= 2000
                    AND year <= 2006));

-- SELECT 
--     d1.last_name
-- FROM
--     director d1,
--     movie_has_director mhd1,
--     movie m1
-- WHERE
--     d1.director_id = mhd1.director_id
--         AND mhd1.movie_id = m1.movie_id
--         AND m1.movie_id IN (SELECT 
--             m.movie_id
--         FROM
--             director d,
--             movie_has_director mhd,
--             movie m
--         WHERE
--             d.director_id = mhd.director_id
--                 AND mhd.movie_id = m.movie_id
--         GROUP BY m.movie_id
--         HAVING COUNT(d.director_id) = 2 and year>=2000 and year<=2006);
	