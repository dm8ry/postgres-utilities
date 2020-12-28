# Postgres DB related scripts
A collection of scripts for management Postgres databases

## Scripts
*  [shell/check_postgres_dbs_size_growth_rate.sh](check_postgres_dbs_size_growth_rate.sh): Check Postgres DB(s) size growth rate
*  [compare_2_dbs_postgres.sh](compare_2_dbs_postgres.sh): Compare Tables and Indexes of 2 DBs in Postgres DB Instance
*  [check_postgres_db_objects_size_growth_rate.sh](check_postgres_db_objects_size_growth_rate.sh): Check Postgres DB objects size growth rate



#### Check Postgres DB(s) size growth rate
```shell script
check_postgres_dbs_size_growth_rate.sh -h localhost -p 5432 -d some_db [-r]
```
#### Compare Tables and Indexes of 2 DBs in Postgres DB Instance
```shell script
compare_2_dbs_postgres.sh -h localhost -p 5432 -d some_db_1 -g localhost -q 5432 -e some_db_2
compare_2_dbs_postgres.sh -h localhost -p 5432 -d some_db_1 -g localhost -q 5432 -e some_db_2 -v
```
#### Check Postgres DB objects size growth rate
```shell script
check_postgres_db_objects_size_growth_rate.sh -h localhost -p 5432 -d some_db [-r]
```
