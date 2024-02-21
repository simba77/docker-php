up:
	docker compose up -d

rebuild:
	docker compose up -d --build --remove-orphans

stop:
	docker compose stop

gen-cert:
	mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost" "adminer.loc"
