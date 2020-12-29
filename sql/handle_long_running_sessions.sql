select pg_terminate_backend(pid) from pg_stat_activity
where pid in (select pid from pg_stat_activity where (now() - pg_stat_activity.query_start) > interval '30 minutes' and state='idle' and usename not in ('rdsadmin'));

select pg_terminate_backend(pid) from pg_stat_activity where pid in (select pid from pg_stat_activity where state='idle' and datname like '%_art' limit 1000);

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE  pid <> pg_backend_pid()
AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') 
AND state_change < current_timestamp - INTERVAL '15' MINUTE;

select *
FROM pg_stat_activity
WHERE  pid <> pg_backend_pid()
AND state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') 
AND state_change < current_timestamp - INTERVAL '10' MINUTE;

select pid, datname, now() - pg_stat_activity.query_start AS duration, query, state
from pg_stat_activity 
where  (now() - pg_stat_activity.query_start) > interval '2 minutes' and state='idle'
order by 2 desc;


select pg_terminate_backend(pid)
from pg_stat_activity
where pid in (select pid
from pg_stat_activity
where  (now() - pg_stat_activity.query_start) > interval '30 minutes' and state='idle');


