SELECT 
    Distinct "yes"
FROM
    movie m,
    movie_has_genre mhg,
    genre g
WHERE
    m.movie_id = mhg.movie_id
        AND mhg.genre_id = g.genre_id
        AND g.genre_name = 'Drama'
        AND m.year = 1995;