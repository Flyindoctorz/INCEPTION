# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cgelgon <cgelgon@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/12 14:05:05 by cgelgon           #+#    #+#              #
#    Updated: 2026/03/12 15:23:47 by cgelgon          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOCKER_COMPOSE = docker-compose -f srcs/docker-compose.yml

all: 
	mkdir -p /home/$(USER)/data/mariadb
	mkdir -p /home/$(USER)/data/wordpress
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d


build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

clean: down
	docker system prune -af
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

fclean: down
	@echo "Cleaning all Docker resources..."
	docker system prune -af --volumes
	@echo "Removing data directories..."
	sudo rm -rf /home/$(USER)/data/mysql
	sudo rm -rf /home/$(USER)/data/wordpress
	@echo "Recreating data directories..."
	mkdir -p /home/$(USER)/data/mysql
	mkdir -p /home/$(USER)/data/wordpress
	@echo "Full clean complete."

re: fclean all

logs:
	$(DOCKER_COMPOSE) logs -f

push:
	@git add .
	@echo -n "$(BLUE)Enter your commit message for Inception: $(END)"
	@read commit_message; \
	git commit -m "Inception\: $$commit_message"; \
	git push; \
	echo "$(YELLOW)📤 All CPP Module  has been pushed with 'Inception\: $$commit_message'$(END)"

# ... tes règles existantes ...

wash:
	@echo "  WARNING: This will remove ALL Docker resources (containers, images, volumes, networks)"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	@echo "Washing away all Docker resources..."
	-docker stop $$(docker ps -qa) 2>/dev/null || true
	-docker rm $$(docker ps -qa) 2>/dev/null || true
	-docker rmi -f $$(docker images -qa) 2>/dev/null || true
	-docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	-docker network rm $$(docker network ls -q) 2>/dev/null || true
	@echo "✨ All Docker resources removed!"
	@echo "Recreating data directories..."
	@mkdir -p /home/$$(USER)/data/mysql
	@mkdir -p /home/$$(USER)/data/wordpress
	@echo "Ready for a fresh build with 'make'"

wash-build : wash all



.PHONY: all build up down clean fclean re wash logs
