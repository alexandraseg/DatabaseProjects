SELECT m.title
FROM movie m, role r, actor a, movie_has_genre mh, genre g
WHERE m.movie_id=r.movie_id AND r.actor_id=a.actor_id AND a.last_name='Allen'
AND m.movie_id=mh.movie_id AND mh.genre_id=g.genre_id AND g.genre_name='Comedy';

-- SELECT 
--     d.director_id
-- FROM
--     director d,
--     movie_has_director mhd,
--     movie m,
--     movie_has_genre mhg,
--     genre g
-- WHERE
--     d.director_id = mhd.director_id
--         AND mhd.movie_id = m.movie_id
--         AND m.movie_id = mhg.movie_id
--         AND mhg.genre_id = g.genre_id
-- GROUP BY d.director_id
-- HAVING count(distinct g.genre_id)>=2;

SELECT 
    m.title, d.last_name
FROM
    actor a,
    role r,
    movie m,
    director d,
    movie_has_director mhd
WHERE
		#join
		a.actor_id = r.actor_id
		#join
        AND r.movie_id = m.movie_id
        # Filter the last name
        AND a.last_name = 'Allen'
        #join
        AND d.director_id = mhd.director_id
        #join
        AND mhd.movie_id = m.movie_id
        AND d.director_id IN (
        # Find directors with two genres
        SELECT 
    d.director_id
FROM
    director d,
    movie_has_director mhd,
    movie m,
    movie_has_genre mhg,
    genre g
WHERE
    d.director_id = mhd.director_id
        AND mhd.movie_id = m.movie_id
        AND m.movie_id = mhg.movie_id
        AND mhg.genre_id = g.genre_id
# Create groups per director 
GROUP BY d.director_id
# filter the groups according to genre count
HAVING count(distinct g.genre_id)>=2);






-- SELECT 
--     d.last_name, m.title
-- FROM
--     director d,
--     movie_has_director mhd,
--     movie m
-- WHERE
--     d.director_id = mhd.director_id
--         AND mhd.movie_id = m.movie_id
--         AND m.title

