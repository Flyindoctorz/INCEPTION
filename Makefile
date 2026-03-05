# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cgelgon <cgelgon@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/12 14:05:05 by cgelgon           #+#    #+#              #
#    Updated: 2026/03/05 10:44:17 by cgelgon          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

DOCKER_COMPOSE = docker-compose -f srcs/docker-compose.yml

all: build up

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

re: clean all

logs:
	$(DOCKER_COMPOSE) logs -f

push:
	@git add .
	@echo -n "$(BLUE)Enter your commit message for Inception: $(END)"
	@read commit_message; \
	git commit -m "Inception\: $$commit_message"; \
	git push; \
	echo "$(YELLOW)📤 All CPP Module  has been pushed with 'Inception\: $$commit_message'$(END)"

.PHONY: all build up down clean fclean re logs