SELECT 
        userid,
        dbid,
        (select datname from pg_database where oid=dbid) db_name,
        substring(query, 1, 500) AS short_query, 
        round(total_time::numeric, 2) AS total_time, 
        calls, 
        round(mean_time::numeric, 2) AS mean, 
        round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu 
FROM 
        pg_stat_statements 
ORDER BY total_time 
DESC LIMIT 20;


SELECT 
        userid,
        dbid,
        substring(query, 1, 50) AS short_query, 
        round(total_time::numeric, 2) AS total_time, 
        calls, 
        round(mean_time::numeric, 2) AS mean, 
        round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu 
FROM 
        pg_stat_statements 
ORDER BY total_time 
DESC LIMIT 20;


SELECT userid,
        substring(query, 1, 50) AS short_query, 
        round(total_time::numeric, 2) AS total_time, 
        calls, 
        round(mean_time::numeric, 2) AS mean, 
        round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu 
FROM 
        pg_stat_statements 
ORDER BY 
        total_time DESC LIMIT 20;


SELECT  pss.userid,
        pa.rolname,
        substring(pss.query, 1, 50) AS short_query,
        round(pss.total_time::numeric, 2) AS total_time,
        pss.calls,
        round(pss.mean_time::numeric, 2) AS mean,
        round((100 * pss.total_time / sum(pss.total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM
        pg_stat_statements pss, pg_authid pa
WHERE
        pss.userid = pa.oid
ORDER BY
        pss.total_time DESC LIMIT 20;


SELECT userid,
       dbid,
       substring(query, 1, 50) AS short_query, 
       round(total_time::numeric, 2) AS total_time, 
       calls, 
       round(mean_time::numeric, 2) AS mean, 
       round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu 
FROM 
       pg_stat_statements 
ORDER BY 
       total_time DESC LIMIT 20;


-- CPU percentage

SELECT  pss.userid,
        pa.rolname,
        round((100 * pss.total_time / sum(pss.total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM
        pg_stat_statements pss, pg_authid pa
WHERE
        pss.userid = pa.oid
ORDER BY
        pss.total_time DESC LIMIT 20;
