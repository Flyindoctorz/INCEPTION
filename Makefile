# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: cgelgon <cgelgon@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/12 14:05:05 by cgelgon           #+#    #+#              #
#    Updated: 2026/01/12 14:05:32 by cgelgon          ###   ########.fr        #
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

re: clean all

logs:
	$(DOCKER_COMPOSE) logs -f

.PHONY: all build up down clean re logs