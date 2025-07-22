#!/bin/sh
#!/bin/sh
for i in 1 2 3 4 5 6 7 8 9 10; do
  mysqladmin ping -h localhost -u root -p"$(cat /run/secrets/db_root_password)" && exit 0
  sleep 2
done
exit 1
