#!/bin/bash



#
#
# Run vacuum analyze for DBs within top active sessions according to pg_stat_activity table
#
#

portNumber=$1

nDepth=3

echo "portNumber=$portNumber"

echo "get databases to handle"

idx=1;

for DB in $(psql -h localhost -p $portNumber -t -c "select db_name from (select datname db_name, count(1) n_of_sessions from pg_stat_activity where state!='idle' group by datname order by 2 desc) M limit $nDepth" postgres); do

echo "#$idx: $DB"

# echo "get db objects-candidates for vacuum analyze"

for OBJCANDIDATE in $(psql -h localhost -p $portNumber -t -c "select relname from pg_stat_all_tables where schemaname = 'public'" $DB); do

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




