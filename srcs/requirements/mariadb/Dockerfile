FROM alpine:3.20

RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils

RUN addgroup mysql || true && \
    adduser -D -G mysql -h /var/lib/mysql -s /bin/sh mysql || true

RUN mkdir -p /var/lib/mysql /var/run/mysqld /etc/mysql/conf.d \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

COPY conf/mariadb.cnf /etc/my.cnf
COPY tools/mariadb_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]