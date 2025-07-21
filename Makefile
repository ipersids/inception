# Include environment variables
-include srcs/.env
export

all: env-check setup build up

env-check:
	@if [ ! -f "srcs/.env" ]; then \
		echo "❌ srcs/.env not found!"; \
		echo "Please create srcs/.env file first"; \
		exit 1; \
	fi

setup: env-check
	@chmod +x srcs/requirements/tools/first_start_setup.sh || sudo chmod +x srcs/requirements/tools/first_start_setup.sh
	@srcs/requirements/tools/first_start_setup.sh

build:
	@docker-compose -f srcs/docker-compose.yml build --no-cache

up:
	@docker-compose -f srcs/docker-compose.yml up

up-d:
	@docker-compose -f srcs/docker-compose.yml up -d

down:
	@docker-compose -f srcs/docker-compose.yml down

clean:
	@docker system prune -f

fclean: down
	@docker-compose -f srcs/docker-compose.yml down -v --rmi all --remove-orphans
	@docker system prune -af --volumes
	@rm -rf $(HOME)/data secrets srcs/.env

re: fclean all

.PHONY: all setup build up up-d down clean fclean