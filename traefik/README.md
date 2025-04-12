# Traefik

[Русская версия](README_RU.md)

Traefik acts as a reverse proxy, automatically routing requests to local domains to the corresponding containers.

## How it works

1. **Traefik operation:** Traefik runs as a Docker Compose container and listens for incoming HTTP/HTTPS requests.
2. **Request routing:** Traefik analyzes the `Host` headers in the requests and, based on the rules defined in `docker-compose.yml`, redirects the requests to the necessary PHP application containers.
3. **Domain management:** Traefik allows the use of convenient local domains (e.g., `myapp.loc`) instead of `localhost:port` for accessing applications.

## Setup and Run

1. **Configuration placement:** It is recommended to place the `traefik/` folder separately from the PHP application project.
2. **Traefik execution:** Run the Traefik container using Docker Compose:

    ```bash
    docker compose up -d
    ```

3. **Network check:** After execution, the `traefik_default` network should appear. All PHP application containers that should be accessible via Traefik must be connected to this network.

    * If the network is not created automatically, create it manually:

        ```bash
        docker network create traefik_default --label "com.docker.compose.network=default"
        ```

4. **Automatic start:** Traefik is configured to start automatically when Docker or the computer is restarted (`restart: always`). If necessary, change this parameter in `docker-compose.yml`.

## Included Services

* **Adminer:** A web interface for managing MariaDB databases. Available at `https://adminer.loc`.
    * Add an entry to the `hosts` file: `127.0.0.1 adminer.loc`.
    * In the Adminer login window:
        * `Server`: the name of the MariaDB container.
        * `Username/Password`: credentials from `.env` or default values from `docker-compose.yml`.
* **MailHog:** A tool for intercepting and viewing outgoing emails from PHP applications. Available at `http://localhost:8025`.
    * Email redirection is configured in the `php.ini` file (`.docker/php-fpm/app.dev.ini`).

## HTTPS Configuration with mkcert

1. **mkcert installation:** Install the `mkcert` utility ([https://github.com/FiloSottile/mkcert](https://github.com/FiloSottile/mkcert)) to generate local SSL certificates.
2. **Certificate generation:** Generate certificates for local domains:

    ```bash
    mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost" "adminer.loc" "myapp.loc" "yourdomain.loc"
    ```

    * List all necessary domains separated by a space.
    * Wildcard certificates for root domains (`*.loc`) may not work in some browsers.

3. **Makefile usage:** The `Makefile` already has a `gen-cert` command for convenient certificate generation. Edit it by adding the necessary domains to the list:

    ```makefile
    gen-cert:
        mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "localhost" "*.localhost" "adminer.loc" "myapp.loc" "yourdomain.loc"
    ```

    * Then run the `make gen-cert` command.

4. **Traefik restart:** After generating the certificates, you need to restart the Traefik container for it to pick up the new certificates, using the `make restart` command:

    ```bash
    make restart
    ```

5. **HTTPS access:** After restarting the container, local sites will be accessible via HTTPS without warnings about an untrusted certificate in the browser.