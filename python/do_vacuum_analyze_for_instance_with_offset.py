import sys, getopt
import psycopg2

def PrintUsage():
   print ("Usage: python {0} -h <db_hostname> -U <db_user> -p <db_port> -d <db_name> -x <start_offset>".format(sys.argv[0]))

# input parameters

inp_database="nops"
inp_user="nops"
inp_port="nops"
inp_hostname="nops"
inp_password="xxx"
inp_start_offset=0

try:
   opts, args = getopt.getopt(sys.argv[1:],"h:U:p:d:x:",["db_hostname=","db_user=","db_port=","db_name=","start_offset="])
except getopt.GetoptError:
   PrintUsage()
   sys.exit(1)
for opt, arg in opts:
   if opt in ("-h", "--db_hostname"):
      inp_hostname = arg
   elif opt in ("-U", "--db_user"):
      inp_user = arg
   elif opt in ("-p", "--db_port"):
      inp_port = arg
   elif opt in ("-d", "--db_name"):
      inp_database = arg
   elif opt in ("-x", "--start_offset"):
      inp_start_offset = arg

# print("len(sys.argv) = {0}".format(len(sys.argv)))

if len(sys.argv) != 11:
    PrintUsage()
    sys.exit(2)

if inp_database == 'nops' or inp_user == 'nops' or inp_port == 'nops' or inp_hostname == 'nops':
    PrintUsage()
    sys.exit(3)

print(" ")
print("* DB_name: ", inp_database)
print("* Username: ", inp_user)
print("* Port: ", inp_port)
print("* Hostname: ", inp_hostname)
print("* Start Offset: ", inp_start_offset)
print(" ")

# processing

con = psycopg2.connect(database=inp_database, user=inp_user, password=inp_password, host=inp_hostname, port=inp_port)

print("* Connect to the Postgres: Ok")
print(" ")

cur = con.cursor()
cur.execute("SELECT datname FROM pg_database where datname not in ('template0', 'template1', 'postgres') offset {0}".format(inp_start_offset))
rows = cur.fetchall()

idx=int(inp_start_offset)+1

for row in rows:
    inp_inp_database=row[0]
    inp_inp_user=row[0]
    print("Database: {0} ({1}|{2})".format(row[0], idx, len(rows)))
    con2 = psycopg2.connect(database=inp_inp_database, user=inp_inp_user, password=inp_password, host=inp_hostname, port=inp_port)
    con2.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)

    print(" ")

    cur2 = con2.cursor()
    sql_query2="SELECT tablename FROM pg_tables where tableowner = '{0}'".format(inp_inp_user)
    cur2.execute(sql_query2)
    rows2 = cur2.fetchall()

    idx2=1
    for row2 in rows2:
       cur2.execute("vacuum analyze", row2[0])
       print("[db:{0}|port:{1}] ({3}|{4}) vacuum analyze {2}".format(inp_inp_database, inp_port, row2[0], idx2, len(rows2)))
       idx2=idx2+1

    nTables2=len(rows2)

    print(" ")
    print("* Total: {0} tables analyzed and vacuumed in Postgres DB: {1}, Port: {2}, Host: {3}".format(nTables2, inp_inp_user, inp_port, inp_hostname))
    print(" ")

    con2.close()

    idx=idx+1

print(" ")
print("* Total databases: {0}".format(len(rows)))
print("* Operation done successfully")
print(" ")
con.close()

