select 
  datname, 
  substr(query, 1, 150) the_query, 
  count(1) 
from 
  pg_stat_activity 
group by datname, substr(query, 1, 150)  
order by 3 desc;
