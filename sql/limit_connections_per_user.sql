SELECT rolname, rolconnlimit
FROM pg_roles
WHERE rolconnlimit <> -1;

ALTER USER johndoe WITH CONNECTION LIMIT 2;
