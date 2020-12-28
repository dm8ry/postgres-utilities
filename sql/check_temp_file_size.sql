SELECT 
  datname, 
  temp_files AS "Temporary files",
  temp_bytes AS "Size of temporary files" 
FROM pg_stat_database;

SELECT 
  datname,
  temp_files AS "Temporary files", 
  pg_size_pretty(temp_bytes) AS "Size of temporary files",
  stats_reset    
FROM pg_stat_database db 
order by temp_bytes desc;

select 
  datname,  
  pg_size_pretty(pg_database_size(datname)) db_size, 
  temp_files, 
  pg_size_pretty(temp_bytes) temp_size, 
  stats_reset 
from pg_stat_database 
order by temp_bytes desc;
