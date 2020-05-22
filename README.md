# Boilerplate for nginx with Let’s Encrypt on docker-compose

> This repository is accompanied by a [step-by-step guide on how to
set up nginx and Let’s Encrypt with Docker](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71).

`init-letsencrypt.sh` fetches and ensures the renewal of a Let’s
Encrypt certificate for a domain in a docker-compose setup with nginx.
This is useful when you need to set up nginx as a reverse proxy for an application.

The default application behind this nginx reverse proxy is a copy of [RequestBin](https://github.com/ericmaino/requestbin)

## Installation
1. [Install docker-compose](https://docs.docker.com/compose/install/#install-compose).

2. Clone this repository: `git clone https://github.com/ericmaino/nginx-certbot.git .`

3. Run the server

        DOMAIN=yourdomain.com EMAIL=domain@yourdomain.com STAGING=0 docker-compose up

## Got questions?
Feel free to post questions in the comment section of the [accompanying guide](https://medium.com/@pentacent/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71)

## License
All code in this repository is licensed under the terms of the `MIT License`. For further information please refer to the `LICENSE` file.
