#!/bin/bash
  

##################################################################################################################################
#
# Name: check_postgres_db_objects_size_growth_rate.sh
#
# Description: Check Postgres DB objects size growth rate
#
# Author: Dmitry
#
# Date: 28-Dec-2020
#
# Usage Example:
#
#     ./check_postgres_db_objects_size_growth_rate.sh -h localhost -p port -d some_db [-r]
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
echo "Check Postgres DB objects size growth rate"
echo " "
echo "DB"
echo "inpHost=$inpHost"
echo "inpPort=$inpPort"
echo "inpDB=$inpDB"
echo " "

if [ $inpReset -eq 1 ]
then

data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

drop table if exists rep_tmp_check_postgres_db_objects_size_growth_rate;

EOF
)

fi

if_rel_exists=0

if_rel_exists=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

select count(1) from pg_class where relname = 'rep_tmp_check_postgres_db_objects_size_growth_rate';

EOF
)

if [ $if_rel_exists -eq 0 ]
then
  
data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

create table if not exists rep_tmp_check_postgres_db_objects_size_growth_rate
(dt timestamp,
dt_yyyy char(4),
dt_mm char(2),
dt_dd char(2),
dt_hh char(2),
dt_mi char(2),
dt_ss char(2),
db_name varchar(100),
obj_name varchar(100),
obj_type varchar(100),
n_of_entries numeric,
obj_size numeric,
obj_size_kb numeric,
obj_size_mb numeric,
obj_size_gb numeric);

EOF
)

fi

data_set_1=$(psql -h $inpHost -p $inpPort -U postgres -d $inpDB -t << EOF

insert into rep_tmp_check_postgres_db_objects_size_growth_rate
select 
now(),
to_char(now(), 'YYYY'),
to_char(now(), 'MM'),
to_char(now(), 'DD'),
to_char(now(), 'HH24'),
to_char(now(), 'MI'),
to_char(now(), 'SS'),
'${inpDB}',
relname,
case 
	when relkind = 'r' then 'Table'
        when relkind = 'i' then 'Index'
        when relkind = 's' then 'Sequence'
        when relkind = 'v' then 'View'
        when relkind = 'm' then 'Materialized View'
        when relkind = 'c' then 'Composite Type'
        when relkind = 't' then 'Toast Table'
        when relkind = 'f' then 'Foreign Table'
        else relkind
end reltype,
reltuples,
relpages::bigint*8*1024,
round(relpages::bigint*8*1024/1024),
round(relpages::bigint*8*1024/1024/1024),
round(relpages::bigint*8*1024/1024/1024/1024)
from pg_class
where relkind in ('r', 'i', 'm');

EOF
)

echo "Snapshots:"

for snapshots in $(psql -h $inpHost -p $inpPort -t -c "select distinct dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss from rep_tmp_check_postgres_db_objects_size_growth_rate order by 1" ${inpDB}); do
echo "$snapshots"
done

echo " "

echo "Enter start snapshot:"  
read start_snapshot

echo "Enter end snapshot:"
read end_snapshot

echo " "

psql -h $inpHost -p $inpPort -U postgres -d $inpDB << EOF

select
   all_the_objs.db_name,
   all_the_objs.obj_name,
   all_the_objs.obj_type,
   a.obj_size obj_size_start_snapshot,
   b.obj_size obj_size_end_snapshot,  
   b.obj_size - a.obj_size as delta_size_B,
   round((b.obj_size - a.obj_size)/1024/1024, 2) as delta_size_MB,
   round(100 * (b.obj_size - a.obj_size) / a.obj_size, 2) percent_change
from
   (select distinct db_name, obj_name, obj_type from rep_tmp_check_postgres_db_objects_size_growth_rate) all_the_objs
left outer join (select * from rep_tmp_check_postgres_db_objects_size_growth_rate where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$start_snapshot') a on a.db_name = all_the_objs.db_name and a.obj_name = all_the_objs.obj_name and a.obj_type = all_the_objs.obj_type
left outer join (select * from rep_tmp_check_postgres_db_objects_size_growth_rate where dt_yyyy||dt_mm||dt_dd||'-'||dt_hh||dt_mi||dt_ss = '$end_snapshot') b on b.db_name = all_the_objs.db_name and b.obj_name = all_the_objs.obj_name and b.obj_type = all_the_objs.obj_type
where (b.obj_size - a.obj_size) > 0
and all_the_objs.obj_name not in ('rep_tmp_check_postgres_db_objects_size_growth_rate')
order by 6 desc;

EOF


