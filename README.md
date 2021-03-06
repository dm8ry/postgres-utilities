# Postgres DB related utilities, scripts and tools
A collection of utilities, scripts and tools for management Postgres databases

## Shell
*  [check_postgres_dbs_size_growth_rate.sh](shell/check_postgres_dbs_size_growth_rate.sh): Check Postgres DB(s) size growth rate
*  [compare_2_dbs_postgres.sh](shell/compare_2_dbs_postgres.sh): Compare Tables and Indexes of 2 DBs in Postgres DB Instance
*  [check_postgres_db_objects_size_growth_rate.sh](shell/check_postgres_db_objects_size_growth_rate.sh): Check Postgres DB objects size growth rate

```
check_postgres_dbs_size_growth_rate.sh -h localhost -p 5432 -d some_db [-r]

compare_2_dbs_postgres.sh -h localhost -p 5432 -d some_db_1 -g localhost -q 5432 -e some_db_2
compare_2_dbs_postgres.sh -h localhost -p 5432 -d some_db_1 -g localhost -q 5432 -e some_db_2 -v

check_postgres_db_objects_size_growth_rate.sh -h localhost -p 5432 -d some_db [-r]
```


## SQL
```
dead_tuples_and_statistics.sql
list_dbs_and_their_size.sql
find_tables_without_primary_keys.sql
temp_file_size.sql
tables_and_indexes_sizes.sql
bloat_in_db.sql
pg_stat_activity_queries.sql
number_active_sessios_per_product.sql
pg_stat_statements_queries.sql
top_read_write_iops.sql
```
 
 
## Python
 
