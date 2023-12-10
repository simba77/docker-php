include .env

up:
	docker compose up -d

rebuild:
	docker compose up -d --build

stop:
	docker compose stop

shell:
	docker exec -it $$(docker ps -q -f name=php-fpm.${APP_NAMESPACE}) /bin/sh
