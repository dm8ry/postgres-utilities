select 
  substr(datname, position('_' in datname)+1, 100) customer_type, 
  count(1) n_of_active_sessions_per_product 
from 
  pg_stat_activity 
where 
  state!='idle' 
group by 
  substr(datname, position('_' in datname)+1, 100) 
order by 2 desc;
