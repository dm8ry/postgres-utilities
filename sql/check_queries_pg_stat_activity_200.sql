select datname, substr(query, 1, 140) the_query, (now() - pg_stat_activity.query_start) takes_time, state, client_addr, pid from pg_stat_activity order by 3 desc;
