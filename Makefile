setup:
	@mkdir -p secrets
	@openssl rand -base64 32 > secrets/db_password.txt
	@openssl rand -base64 32 > secrets/db_root_password.txt
	@curl -s https://api.wordpress.org/secret-key/1.1/salt/ > secrets/credentials.txt
	mkdir -p ${HOME}/data/mariadb
	mkdir -p ${HOME}/data/wordpress
	chmod 755 ${HOME}/data
	chmod 755 ${HOME}/data/mariadb
	chmod 755 ${HOME}/data/wordpress
	echo "Data directories created for user: ${HOME}"
	echo "\nMove .env file to ~/srcs\n"

all: setup build up

up:
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

build:
	docker-compose -f srcs/docker-compose.yml build --no-cache

fclean: down
	docker system prune -a
	docker volume prune -a
	rm -rf ${HOME}/data/mariadb
	rm -rf ${HOME}/data/wordpress