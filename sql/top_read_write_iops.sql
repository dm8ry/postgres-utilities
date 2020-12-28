
-- top read IOPs

select
        substr(query,1,150) the_query,
        pd.datname,
        (shared_blks_read+local_blks_read) read_IOPS
from
        pg_stat_statements pss,
        pg_database pd
where
        pss.queryid is not null
and
        pss.dbid = pd.oid
order by
        (shared_blks_read+local_blks_read) desc;

-- top write IOPs

select
        substr(query,1,150) the_query,
        pd.datname,
        (shared_blks_written+local_blks_written) write_IOPS
from
        pg_stat_statements pss,
        pg_database pd
where
        pss.queryid is not null
and
        pss.dbid = pd.oid
order by
        (shared_blks_written+local_blks_written) desc;




SELECT
left(query, 50) AS short_query
,calls
,total_time
,rows
,calls*total_time*rows as Volume
FROM pg_stat_statements
WHERE
(query ilike '%update%'
or query ilike '%insert%'
or query ilike '%delete%')
and query not like '%aurora_replica_status%'
and query not like '%rds_heartbeat%'
ORDER BY Volume DESC LIMIT 20;


SELECT
left(query, 50) AS short_query
,calls
,total_time
,rows
,calls*total_time*rows as Volume
FROM pg_stat_statements
ORDER BY Volume DESC LIMIT 20;


select
	pd.datname,
	left(pss.query, 100) AS short_query,
	calls num_of_calls,
	total_time total_time_ms,
	rows,
	calls*total_time*rows as Volume
	
from
        pg_stat_statements pss,
        pg_database pd
where
        pss.queryid is not null
and
        pss.dbid = pd.oid
order by
        6 desc;
