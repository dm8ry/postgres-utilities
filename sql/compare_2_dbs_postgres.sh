#!/bin/bash


##################################################################################################################################
#
# Name: Compare 2 Postgres DBs
#
# Description: Compare Tables and Indexes of 2 DBs in Postgres
#
# Author: Dmitry
#
# Date: 26-Dec-2020
#
# Usage Example: 
#
#     ./compare_2_dbs_postgres.sh -h localhost -p 15436 -d some_db_1 -g localhost -q 15436 -e some_db_2
#     ./compare_2_dbs_postgres.sh -h localhost -p 15436 -d some_db_1 -g localhost -q 15436 -e some_db_2 -v
#
####################################################################################################################################


helpFunction()
{
   echo ""
   echo "Usage: $0 -h hostname1 -p port1 -d dbname1 -g hostname2 -q port2 -e dbname2"
   echo -e "\t-h Postgres hostname1"
   echo -e "\t-p Postgers port1"
   echo -e "\t-d Postgres db1 to compare"
   echo -e "\t-g Postgres hostname2"
   echo -e "\t-q Postgers port2"
   echo -e "\t-e Postgres db2 to compare"
   echo -e "\t-v Verbose"
   exit 1 # Exit script after printing help
}

inpVerbose=0

while getopts "h:p:d:g:q:e:v" opt
do
   case "$opt" in
      h ) inpHost1="$OPTARG" ;;
      p ) inpPort1="$OPTARG" ;;
      d ) inpDB1="$OPTARG" ;;
      g ) inpHost2="$OPTARG" ;;
      q ) inpPort2="$OPTARG" ;;
      e ) inpDB2="$OPTARG" ;;
      v ) inpVerbose=1 ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$inpHost1" ] || [ -z "$inpPort1" ] || [ -z "$inpDB1" ] || [ -z "$inpHost2" ] || [ -z "$inpPort2" ] || [ -z "$inpDB2" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct

echo " "
echo "Compare 2 Postgres DBs"
echo " "
echo "DB1"
echo "inpHost1=$inpHost1"
echo "inpPort1=$inpPort1"
echo "inpDB1=$inpDB1"
echo " "
echo "DB2"
echo "inpHost2=$inpHost2"
echo "inpPort2=$inpPort2"
echo "inpDB2=$inpDB2"
echo " "

# run statistics

echo "Vacuum databases and calculate statistics"

vacuumdb -h $inpHost1 -p $inpPort1 -U postgres -j 4 -z $inpDB1

vacuumdb -h $inpHost2 -p $inpPort2 -U postgres -j 4 -z $inpDB2

echo " "

# Compare Tables

data_set_1=$(psql -h $inpHost1 -p $inpPort1 -U postgres -d $inpDB1 -t << EOF
select 
       n.nspname as table_schema,
       c.relname as table_name,
       c.reltuples as rows
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
      and n.nspname not in ('information_schema','pg_catalog')
order by c.reltuples desc;
EOF
)

data_set_2=$(psql -h $inpHost2 -p $inpPort2 -U postgres -d $inpDB2 -t << EOF
select 
       n.nspname as table_schema,
       c.relname as table_name,
       c.reltuples as rows
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind = 'r'
      and n.nspname not in ('information_schema','pg_catalog')
order by c.reltuples desc;
EOF
)

temp_file_1="./tmp_tables_db1.tmp"
temp_file_2="./tmp_tables_db2.tmp"

echo "$data_set_1" > ${temp_file_1}
echo "$data_set_2" > ${temp_file_2}

if [ $inpVerbose -eq 1 ]
then
  echo " "
  echo "Tables in the DB $inpDB1"
  cat ${temp_file_1}
  echo " "
  echo "Tables in the DB $inpDB2"
  cat ${temp_file_2}
  echo " "
fi

echo "Not matching tables:"

echo " "
echo "Exists in the DB $inpDB1 and DOES NOT exist in the DB $inpDB2"
grep -vf ${temp_file_2} ${temp_file_1}

echo " "

echo "Exists in the DB $inpDB2 and DOES NOT exist in the DB $inpDB1"
grep -vf ${temp_file_1} ${temp_file_2}

echo " "

# Compare Indexes

data_set_3=$(psql -h $inpHost1 -p $inpPort1 -U postgres -d $inpDB1 -t << EOF
SELECT
     n.nspname  as "schema"
    ,t.relname  as "table"
    ,c.relname  as "index"
    ,pg_get_indexdef(indexrelid) as "def"
FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON n.oid        = c.relnamespace
    JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
    JOIN pg_catalog.pg_class t ON i.indrelid   = t.oid
WHERE c.relkind = 'i'
    and n.nspname not in ('pg_catalog', 'pg_toast')
    and pg_catalog.pg_table_is_visible(c.oid)
ORDER BY
     n.nspname
    ,t.relname
    ,c.relname
EOF
)

data_set_4=$(psql -h $inpHost2 -p $inpPort2 -U postgres -d $inpDB2 -t << EOF
SELECT
     n.nspname  as "schema"
    ,t.relname  as "table"
    ,c.relname  as "index"
    ,pg_get_indexdef(indexrelid) as "def"
FROM pg_catalog.pg_class c
    JOIN pg_catalog.pg_namespace n ON n.oid        = c.relnamespace
    JOIN pg_catalog.pg_index i ON i.indexrelid = c.oid
    JOIN pg_catalog.pg_class t ON i.indrelid   = t.oid
WHERE c.relkind = 'i'
    and n.nspname not in ('pg_catalog', 'pg_toast')
    and pg_catalog.pg_table_is_visible(c.oid)
ORDER BY
     n.nspname
    ,t.relname
    ,c.relname
EOF
)

temp_file_3="./tmp_indexes_db1.tmp"
temp_file_4="./tmp_indexes_db2.tmp"

echo "$data_set_3" > ${temp_file_3}
echo "$data_set_4" > ${temp_file_4}

if [ $inpVerbose -eq 1 ]
then
  echo " "
  echo "Indexes in the DB $inpDB1"
  cat ${temp_file_3}
  echo " "
  echo "Indexes in the DB $inpDB2"
  cat ${temp_file_4}
  echo " "
fi

echo "Not matching indexes:"

echo " "
echo "Exists in the DB $inpDB1 and DOES NOT exist in the DB $inpDB2"
grep -vf ${temp_file_4} ${temp_file_3}

echo " "

echo "Exists in the DB $inpDB2 and DOES NOT exist in the DB $inpDB1"
grep -vf ${temp_file_3} ${temp_file_4}

echo " "


