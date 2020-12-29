#!/bin/bash

#
#
# Run vacuum analyze for top pg_stat_activity databases
#
#

portNumber=$1

nDepth=15

echo "portNumber=$portNumber"

echo "get databases to handle"

idx=1;

for DB in $(psql -h localhost -p $portNumber -t -c "select db_name from (select datname db_name, count(1) n_of_sessions from pg_stat_activity group by datname order by 2 desc) M limit $nDepth" postgres); do

echo "#$idx: $DB"

# echo "get db objects-candidates for vacuum analyze"

for OBJCANDIDATE in $(psql -h localhost -p $portNumber -t -c "select relname from pg_stat_all_tables where schemaname = 'public' and n_dead_tup > 0 order by n_dead_tup desc" $DB); do

# echo " $DB.$OBJCANDIDATE"

retMessage=$(psql -h localhost -p $portNumber -t -c "vacuum analyze $OBJCANDIDATE" $DB)

if [ "$retMessage" = "VACUUM" ]; then 
 echo " $DB.$OBJCANDIDATE - Ok"
else
 echo " $DB.$OBJCANDIDATE - Not Ok"
fi

done

idx=$((idx+1))

done


