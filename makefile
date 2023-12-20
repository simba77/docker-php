include .env

up:
	docker compose up -d

rebuild:
	docker compose up -d --build

stop:
	docker compose stop

shell:
	docker exec -it $$(docker ps -q -f name=${COMPOSE_PROJECT_NAME}-php-fpm) /bin/sh
