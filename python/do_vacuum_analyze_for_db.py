import sys, getopt
import psycopg2

def PrintUsage():
   print ("Usage: python {0} -h <db_hostname> -U <db_user> -p <db_port> -d <db_name>".format(sys.argv[0]))

# input parameters

inp_database="nops"
inp_user="nops"
inp_port="nops"
inp_hostname="nops"
inp_password="xxx"

try:
   opts, args = getopt.getopt(sys.argv[1:],"h:U:p:d:",["db_hostname=","db_user=","db_port=","db_name="])
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

# print("len(sys.argv) = {0}".format(len(sys.argv)))

if len(sys.argv) != 9:
    PrintUsage()
    sys.exit(2)

if inp_database == 'nops' or inp_user == 'nops' or inp_port == 'nops' or inp_hostname == 'nops':
    PrintUsage()
    sys.exit(3)

# print(" ")
# print("-- DB_name: ", inp_database)
# print("-- Username: ", inp_user)
# print("-- Port: ", inp_port)
# print("-- Hostname: ", inp_hostname)
# print(" ")

# processing

con = psycopg2.connect(database=inp_database, user=inp_user, password=inp_password, host=inp_hostname, port=inp_port)
con.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)

print(" ")
print("-- Connect to the Postgres: Ok")

cur = con.cursor()
sql_query="SELECT tablename FROM pg_tables where tableowner = '{0}'".format(inp_user)
cur.execute(sql_query)
rows = cur.fetchall()

print(" ")
print("-- DB_name: ", inp_database)
print("-- Username: ", inp_user)
print("-- Port: ", inp_port)
print("-- Hostname: ", inp_hostname)
print(" ")

print("-- Analyze and Vacuum tables --")
print(" ")

for row in rows:
    cur.execute("vacuum analyze", row[0])
    print("vacuum analyze {0}".format(row[0]))

nTables=len(rows)

print(" ")
print("Total: {0} tables analyzed and vacuumed in Postgres DB: {1}, Port: {2}, Host: {3}".format(nTables, inp_user, inp_port, inp_hostname))
print(" ")

print("-- Operation done successfully --")
con.close()

