select datname, substr(query, 1, 150) the_query, (now() - pg_stat_activity.query_start) takes_time, state, client_addr, pid from pg_stat_activity  order by 3 desc;

select 
  datname, 
  substr(query, 1, 150) the_query, 
  count(1) 
from 
  pg_stat_activity 
group by datname, substr(query, 1, 150)  
order by 3 desc;

