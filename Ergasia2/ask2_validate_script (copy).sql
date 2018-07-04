# --------------------------------------
# --------------------------------------
DROP PROCEDURE IF EXISTS ValidateQuery;
DELIMITER //
CREATE PROCEDURE ValidateQuery(IN qNum INT, IN queryTableName VARCHAR(255))
BEGIN
	DECLARE cname VARCHAR(64);
	DECLARE done INT DEFAULT FALSE;
	DECLARE cur CURSOR FOR SELECT c.column_name FROM information_schema.columns c WHERE 
c.table_schema='movies' AND c.table_name=queryTableName;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	# Add the column fingerprints into a tmp table
	DROP TABLE IF EXISTS cFps;
	CREATE TABLE cFps (
  	  `val` VARCHAR(50) NOT NULL
	) 
	ENGINE = InnoDB;

	OPEN cur;
	read_loop: LOOP
		FETCH cur INTO cname;
		IF done THEN
      			LEAVE read_loop;
    		END IF;
		
		DROP TABLE IF EXISTS ordered_column;
		SET @order_by_c = CONCAT('CREATE TABLE ordered_column as SELECT ', cname, ' FROM ', queryTableName, ' ORDER BY ', cname);
		PREPARE order_by_c_stmt FROM @order_by_c;
		EXECUTE order_by_c_stmt;
		
		SET @query = CONCAT('SELECT md5(group_concat(', cname, ', "")) FROM ordered_column INTO @cfp');
		PREPARE stmt FROM @query;
		EXECUTE stmt;

		INSERT INTO cFps values(@cfp);
		DROP TABLE IF EXISTS ordered_column;
	END LOOP;
	CLOSE cur;

	# Order fingerprints
	DROP TABLE IF EXISTS oCFps;
	SET @order_by = 'CREATE TABLE oCFps as SELECT val FROM cFps ORDER BY val'; 
	PREPARE order_by_stmt FROM @order_by;
	EXECUTE order_by_stmt;

	# Read the values of the result
	SET @q_yours = 'SELECT md5(group_concat(val, "")) FROM oCFps INTO @yours';
	PREPARE q_yours_stmt FROM @q_yours;
	EXECUTE q_yours_stmt;

	SET @q_fp = CONCAT('SELECT fp FROM fingerprints WHERE qnum=', qNum,' INTO @rfp');
	PREPARE q_fp_stmt FROM @q_fp;
	EXECUTE q_fp_stmt;

	SET @q_diagnosis = CONCAT('select IF(@rfp = @yours, "OK", "ERROR") into @diagnosis');
	PREPARE q_diagnosis_stmt FROM @q_diagnosis;
	EXECUTE q_diagnosis_stmt;

	INSERT INTO results values(qNum, @rfp, @yours, @diagnosis);

	DROP TABLE IF EXISTS cFps;
	DROP TABLE IF EXISTS oCFps;
END//
DELIMITER ;

# --------------------------------------

# Execute queries (Insert here your queries).

# Validate the queries
drop table if exists results;
CREATE TABLE results (
  `qnum` INTEGER  NOT NULL,
  `rfp` VARCHAR(50)  NOT NULL,
  `yours` VARCHAR(50)  NOT NULL,
  `diagnosis` VARCHAR(10)  NOT NULL
)
ENGINE = InnoDB;


# -------------
# Q1
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

SELECT m.title
FROM movie m, role r, actor a, movie_has_genre mh, genre g
WHERE m.movie_id=r.movie_id AND r.actor_id=a.actor_id AND a.last_name='Allen'
AND m.movie_id=mh.movie_id AND mh.genre_id=g.genre_id AND g.genre_name='Comedy';

CALL ValidateQuery(1, 'q');
drop table if exists q;
# -------------


# -------------
# Q2
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

SELECT 
    m.title, d.last_name
FROM
    actor a,
    role r,
    movie m,
    director d,
    movie_has_director mhd
WHERE
    a.actor_id = r.actor_id
        AND r.movie_id = m.movie_id
        AND a.last_name = 'Allen'
        AND d.director_id = mhd.director_id
        AND mhd.movie_id = m.movie_id
        AND d.director_id IN (SELECT 
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
GROUP BY d.director_id
HAVING count(distinct g.genre_id)>=2);

CALL ValidateQuery(2, 'q');
drop table if exists q;
# -------------


# -------------
# Q3
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

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

CALL ValidateQuery(3, 'q');
drop table if exists q;
# -------------


# -------------
# Q4
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

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

CALL ValidateQuery(4, 'q');
drop table if exists q;
# -------------


# -------------
# Q5
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

SELECT DISTINCT
    LEAST(d.last_name, d2.last_name) AS director1,
    GREATEST(d.last_name, d2.last_name) AS director2
FROM
    director d,
    director d2,
    movie_has_director mhd,
    movie_has_director mhd2,
    movie m
WHERE
    d.director_id = mhd.director_id
        AND mhd.movie_id = m.movie_id
        AND d2.director_id = mhd2.director_id
        AND mhd2.movie_id = m.movie_id
        AND mhd2.movie_id = mhd.movie_id
        AND d.director_id <> d2.director_id
        AND m.year >= 2000
        AND m.year <= 2006
        AND d.director_id IN (SELECT 
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
        GROUP BY d.director_id
        HAVING COUNT(DISTINCT g.genre_id) >= 6)
        AND d2.director_id IN (SELECT 
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
        GROUP BY d.director_id
        HAVING COUNT(DISTINCT g.genre_id) >= 6);

CALL ValidateQuery(5, 'q');
drop table if exists q;
# -------------


# -------------
# Q6
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

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

CALL ValidateQuery(6, 'q');
drop table if exists q;
# -------------


# -------------
# Q7
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

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
        AND g2.genre_id IN (SELECT 
            distinct max(g.genre_id)
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

CALL ValidateQuery(7, 'q');
drop table if exists q;
# -------------


# -------------
# Q8
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

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

CALL ValidateQuery(8, 'q');
drop table if exists q;
# -------------


# -------------
# Q9
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

select * from actor a where a.actor_id = 933;

CALL ValidateQuery(9, 'q');
drop table if exists q;
# -------------


# -------------
# Q10
drop table if exists q;
create table q as # Do NOT delete this line. Add the query below.

select * from actor a where a.actor_id = 933;

CALL ValidateQuery(10, 'q');
drop table if exists q;
# -------------

DROP PROCEDURE IF EXISTS RealValue;
DROP PROCEDURE IF EXISTS ValidateQuery;
DROP PROCEDURE IF EXISTS RunRealQueries;