SELECT 
  pg_database.datname as "database_name", 
  pg_database_size(pg_database.datname)/1024/1024 AS size_in_mb 
FROM 
 pg_database 
WHERE 
  pg_database.datname like '%_xray' 
ORDER by 2 DESC;
