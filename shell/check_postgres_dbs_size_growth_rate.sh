#!/bin/bash
  

##################################################################################################################################
#
# Name: check_postgres_dbs_size_growth_rate.sh
#
# Description: Check Postgres DBs size growth rate
#
# Author: Dmitry
#
# Date: 28-Dec-2020
#
# Usage Example:
#
#     ./check_postgres_dbs_size_growth_rate.sh -h localhost -p port -d some_db [-r]
#
####################################################################################################################################


helpFunction()
{
   echo ""
   echo "Usage: $0 -h hostname -p port -d dbname -r"
   echo -e "\t-h Postgres hostname"
   echo -e "\t-p Postgers port"
   echo -e "\t-d Postgres db"
   echo -e "\t-r Reset"
   exit 1 # Exit script after printing help
}

inpReset=0

while getopts "h:p:d:r" opt
do
   case "$opt" in
      h ) inpHost="$OPTARG" ;;
      p ) inpPort="$OPTARG" ;;
      d ) inpDB="$OPTARG" ;;
      r ) inpReset=1 ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$inpHost" ] || [ -z "$inpPort" ] || [ -z "$inpDB" ] 
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct

echo " "
echo "Check Postgres DBs size growth rate"
echo " "
echo "DB"
echo "inpHost=$inpHost"
echo "inpPort=$inpPort"
echo "inpDB=$inpDB"
echo " "

if [ $inpReset -eq 1 ]
then

data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

drop table if exists rep_tmp_check_growth_rate_postgres_db;

EOF
)

fi

if_rel_exists=0

if_rel_exists=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

select count(1) from pg_class where relname = 'rep_tmp_check_growth_rate_postgres_db';

EOF
)

if [ $if_rel_exists -eq 0 ]
then
  
data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

create table if not exists rep_tmp_check_growth_rate_postgres_db
(dt timestamp,
dt_yyyy char(4),
dt_mm char(2),
dt_dd char(2),
dt_hh char(2),
dt_mi char(2),
dt_ss char(2),
db_name varchar(100),
db_size_kb numeric,
db_size_mb numeric,
db_size_gb numeric);

EOF
)

fi

data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

insert into rep_tmp_check_growth_rate_postgres_db
select 
now(),
to_char(now(), 'YYYY'),
to_char(now(), 'MM'),
to_char(now(), 'DD'),
to_char(now(), 'HH24'),
to_char(now(), 'MI'),
to_char(now(), 'SS'),
datname,
pg_database_size(pg_database.datname)/1024,
pg_database_size(pg_database.datname)/1024/1024,
pg_database_size(pg_database.datname)/1024/1024/1024
from pg_database
where datname not in ('azure_maintenance');

EOF
)

echo "Snapshots:"

for snapshots in $(psql -h $inpHost -p $inpPort -t -c "select distinct dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss from rep_tmp_check_growth_rate_postgres_db order by 1" postgres); do
echo "$snapshots"
done

echo " "

echo "Enter start snapshot:"  
read start_snapshot

echo "Enter end snapshot:"
read end_snapshot

echo " "
echo "Top By Percentage"
echo " "

psql -h $inpHost -p $inpPort -U postgres -d $inpDB << EOF

select
   all_the_dbs.db_name,
   a.db_size_kb,
   b.db_size_kb,  
   b.db_size_kb - a.db_size_kb as delta_size_kb,
   round(100 * (b.db_size_kb - a.db_size_kb) / a.db_size_kb, 2) percent_change
from
   (select distinct db_name from rep_tmp_check_growth_rate_postgres_db) all_the_dbs
left outer join (select * from rep_tmp_check_growth_rate_postgres_db where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$start_snapshot') a on a.db_name = all_the_dbs.db_name
left outer join (select * from rep_tmp_check_growth_rate_postgres_db where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$end_snapshot') b on b.db_name = all_the_dbs.db_name
where (b.db_size_kb - a.db_size_kb) > 0
order by 5 desc;

EOF

echo " "
echo "Top By Difference"
echo " "

psql -h $inpHost -p $inpPort -U postgres -d $inpDB << EOF

select
   all_the_dbs.db_name,
   a.db_size_kb,
   b.db_size_kb,
   b.db_size_kb - a.db_size_kb as delta_size_kb,
   round(100 * (b.db_size_kb - a.db_size_kb) / a.db_size_kb, 2) percent_change
from
   (select distinct db_name from rep_tmp_check_growth_rate_postgres_db) all_the_dbs
left outer join (select * from rep_tmp_check_growth_rate_postgres_db where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$start_snapshot') a on a.db_name = all_the_dbs.db_name
left outer join (select * from rep_tmp_check_growth_rate_postgres_db where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$end_snapshot') b on b.db_name = all_the_dbs.db_name
where (b.db_size_kb - a.db_size_kb) > 0
order by 4 desc;

EOF
