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

setup:
	@if [ ! -d "secrets" ]; then \
		chmod +x srcs/requirements/tools/first_start_setup.sh || sudo chmod +x srcs/requirements/tools/first_start_setup.sh; \
		srcs/requirements/tools/first_start_setup.sh; \
	fi

build:
	docker-compose -f srcs/docker-compose.yml build

up:
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean:
	@docker-compose -f srcs/docker-compose.yml down --remove-orphans
	@docker system prune -f
	@echo "Basic Docker cleanup done."

fclean: clean
	@docker-compose -f srcs/docker-compose.yml down -v --rmi all --remove-orphans
	@docker system prune -af --volumes
	@echo "Docker images, volumes, and orphans fully removed."

dclean: fclean
	@echo "Removing persistent local data and secrets..."
	@sudo rm -rfv $(HOME)/data secrets srcs/.env || echo "Some files may not exist or couldn't be deleted."
	@echo "Project directory fully reset."
re: fclean all

.PHONY: all setup build up up-d down clean fclean dclean
