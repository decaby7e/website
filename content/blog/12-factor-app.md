---
title: Bootstrapping Our 12 Factor App with GitHub Actions, Docker Compose, and Digital Ocean
date: 2021-08-02
author: Jack Polk
tags: ["devlog", "devops"]
draft: false
layout: post
---

> This post was cross-posted from <https://cliqteam.com/blog/ci-bootstrap/>

I love the problem solving that comes along with programming applications. But I
also love the problem solving required to deploy and scale those applications.
For the past 10 years of my life, I have invested immense amounts of time into
not only learning how to program but how to administer Linux machines and deploy
applications onto those machines. My perfectionism has not allowed me to stick
with conventional methods and I have only begun to scratch the surface of cloud
applications and technologies such as CI/CD, containers, container
orchestration, and about a 100 other topics I have to learn about.

The when2meet application for me is a perfect place to start applying the skills
I have learned up to this point in a productive but safe manner. Wouldn't want
to start working on mission critical services at Google without getting my feet
wet first ;)

## What is a 12 Factor App?

As put by the [12 factor app specification](https://12factor.net/):

> In the modern era, software is commonly delivered as a service: called web apps, or software-as-a-service. The twelve-factor app is a methodology for building software-as-a-service apps that:
>
> - Use declarative formats for setup automation, to minimize time and cost for new developers joining the project;
> - Have a clean contract with the underlying operating system, offering maximum portability between execution environments;
> - Are suitable for deployment on modern cloud platforms, obviating the need for servers and systems administration;
> - Minimize divergence between development and production, enabling continuous deployment for maximum agility;
> - And can scale up without significant changes to tooling, architecture, or development practices.
>
> The twelve-factor methodology can be applied to apps written in any
> programming language, and which use any combination of backing services
> (database, queue, memory cache, etc).

This standard acts as a guideline for most if not all of the design decisions
that were made while constructing the structure of this application.

## Project Structure and Requirements

The project, as of the time of writing, is structured in the following manner:

```tree
├── backend
│   ├── api
│   │   └── ...
│   ├── config
│   │   └── ...
│   ├── core
│   │   └── ...
│   ├── manage.py
│   ├── requirements.txt
│   └── run_tests.sh
├── docker
│   ├── backend
│   │   ├── dev.sh
│   │   ├── Dockerfile.local
│   │   ├── Dockerfile.prod
│   │   ├── entrypoint.sh
│   │   ├── prod.sh
│   │   └── test.sh
│   └── frontend
│       ├── Dockerfile.local
│       └── Dockerfile.prod
├── docker-compose.yaml
├── frontend
│   ├── ...
│   ├── package.json
│   ├── package-lock.json
│   ├── public
│   │   └── ...
│   └── src
│       └── ...
├── README.md
└── TODO.md
```

The **backend** folder is a Django application primarily constructed around the
[Django REST Framework](https://www.django-rest-framework.org/). We love Python
and we also love Django, as they let us get to making the app rather than
worrying about implementation details that are often better left to people more
invested in doing it right once and maintaining that over time.

The **frontend** folder is a Vue app. Nothing particularly interesting here
other than that Vue applications are _miles_ ahead of the frontend capabilities
of Django templates (nice as they may have been 10 years ago).

The **docker** folder is a space for Docker images and their related resources.
We currently use `Dockerfile.local` for local images that are primarily for
dependency isolation and all our code is mounted with volumes to containers to
allow for rapid development that would be severely hindered by needing to rebuild
images. `Dockerfile.prod` uses multi-stage builds and planned layering to reduce image
size and complexity. This is used in our staging and production environments.

Our **docker-compose.yaml** is defined and optimized around local use. We have
another that is externally defined for our production and staging environments
that is very close but utilizes production images for optimizations not found in
development.

## Docker and Docker Compose

Using containers was a given for following 12-factor app standards. Using Docker
was also a given due to its popularity and amazing feature set.
[Podman](https://podman.io/) was also considered but Docker is just so widely
supported and easy to use for our developers.

Docker Compose was also a given due to the amount of configuration and
environment setup that it can accomplish efficiently and quickly in a single
file! We configure our proxy, application configuration, ports, volumes, etc. in
this one file and use a similar one in our staging environment for simplicity
and consistency.

The following is an example of what our compose file looks like:

```yaml
version: "3"

services:
  backend:
    image: ghcr.io/cliqteam/when2meet-backend:local
    build:
      context: .
      dockerfile: ./docker/backend/Dockerfile.local

    restart: unless-stopped
    command: /dev.sh
    depends_on:
      - postgres
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.backend.rule=Host(`localhost`) && (PathPrefix(`/api`) || PathPrefix(`/static`))"
      - "traefik.http.routers.backend.entrypoints=web"
      - "traefik.http.middlewares.xForwardedProto.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.backend.middlewares=xForwardedProto"

    volumes:
      - ./backend:/app
    environment:
      - SECRET_KEY=${SECRET_KEY}
      - RECAPTCHA_SECRET_KEY=${RECAPTCHA_SECRET_KEY}
      - RECAPTCHA_SITE_KEY=${RECAPTCHA_SITE_KEY}
      - SQL_USER={{REDACTED}}
      - SQL_PASSWORD={{REDACTED}}
      - SQL_DATABASE={{REDACTED}}
      - SQL_HOST=postgres
      - SQL_PORT=5432

  frontend:
    image: ghcr.io/cliqteam/when2meet-frontend:local
    build:
      context: .
      dockerfile: ./docker/frontend/Dockerfile.local

    restart: unless-stopped
    tty: true
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`localhost`) && PathPrefix(`/`)"
      - "traefik.http.routers.frontend.entrypoints=web"
    volumes:
      - ./frontend:/app
      - /app/node_modules

  ingress:
    image: traefik:v2.4

    # Enables the web UI and tells Traefik to listen to docker
    command:
      - "--api.insecure=true"
      - "--providers.docker"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:8000"
    depends_on:
      - backend
      - frontend

    ports:
      # The HTTP port
      - "8000:8000"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock

  postgres:
    image: postgres:12.3-alpine

    restart: unless-stopped
    logging:
      driver: none

    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER={{REDACTED}}
      - POSTGRES_PASSWORD={{REDACTED}}
      - POSTGRES_DB={{REDACTED}}

volumes:
  postgres-data:
```

What's nice about the use of Traefik for our ingress proxy is that configuration
can be defined per container and it removes the need for potentially complex and
arguably more clunky file-based configuration.

## GitHub Actions

While I am very partial to [Concourse CI](https://concourse-ci.org/) and it was
what introduced me to CI concepts to begin with, [GitHub
Actions](https://docs.github.com/en/actions) was the go-to for us given that we
use GitHub for code versioning and project management. We setup three main
workflows that capture the core of the kind of continuous integration that we
need.

Frontend and backend testing and building is done with the same
`docker-compose.yaml` that is used by our developers, maintaining environment
consistency and simplifying the workflow itself by abstracting the processes of
environment setup to the Dockerfile. Why repeat the steps of installing
dependencies and preparing the environment when Docker is already doing that?
Both of these workflows roughly follow this template:

```yaml
name: backend

on:
  push:
    paths:
      - docker/backend/**
      - backend/**
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  COMPOSE_FILE: docker-compose.yaml
  IMAGE_NAME: cliqteam/when2meet-backend
  IMAGE_DOCKERFILE: docker/backend/Dockerfile.prod

jobs:
  testing:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Log in to the Container registry
        uses: docker/login-action@f054a8b539a109f9f41c372932f1ae047eff08c9
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ {{REDACTED}} }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Build docker images
        run: docker-compose build backend

      - name: Run tests
        run: |
          docker-compose run \
            --rm \
            -e APP_DOMAIN=localhost \
            -e SECRET_KEY=${{ {{REDACTED}} }} \
            -e RECAPTCHA_SECRET_KEY=${{ {{REDACTED}} }} \
            -e RECAPTCHA_SITE_KEY=${{ {{REDACTED}} }} \
            backend /test.sh

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: docker/metadata-action@98669ae865ea3cffbcbaa878cf57c20bbf1c6c38
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}

      - name: Build and push Docker image
        uses: docker/build-push-action@ad44023a93711e3deb337508980b4b5e9bcdc5dc
        with:
          file: ${{ env.IMAGE_DOCKERFILE }}
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

Rather than building a binary and deploying that as a release to GitHub, we
utilize Docker images for a similar purpose. Many web applications, especially
those written in Python, PHP, etc. (interpreted languages) are not single
binaries but rather a collection of source files sat behind a CGI server. Docker
images allow us to make a "pseudo-binary" of sorts which can be distributed to
one or more servers.

Our staging environment is continuously deployed also using an actions workflow.
This uses images built by the previous workflow:

```yaml
name: Deploy to Staging

on:
  workflow_run:
    workflows: ["backend", "frontend"]
    branches: [staging]
    types:
      - completed
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  COMPOSE_ROOT: /srv/when2meet/compose

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      packages: read

    steps:
      - name: Pull images and start services on staging server
        uses: garygrossgarten/github-action-ssh@release
        with:
          command: |
            echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
            cd ${{ env.COMPOSE_ROOT }}
            docker-compose down
            docker-compose pull
            docker-compose up -d || exit 1
          host: ${{ {{REDACTED}} }}
          username: root
          privateKey: ${{ {{REDACTED}} }}
```

## Deployment (Digital Ocean and Ansible)

The last thing I'd want is to get nice and cozy with a cloud provider and let
them do all the hard work of deploying my application for me. I'm a programmer
for God's sake! Let me figure it out myself!

In all seriousness, the problem of vendor lock-in is a very real one and one
that we would like to avoid for reasons that range from financial to practical.
The ability to switch providers if we want/need to or to even host our
applications on our own infrastructure not only tickles my libertarian bone but
gives us independence as developers to deploy our app as we see fit.

For our cloud provider, we decided to go with **Digital Ocean**. I personally
love them due to their fair prices, reliability (my personal Droplet has an
uptime of over 1 year!), and simplicity. We didn't go crazy and spin up a
Kubernetes cluster (yet ;)) but instead bought a small Droplet and installed
Ubuntu 20.04 on it with Docker. We use compose as the container orchestrator and
images are pulled from our GitHub actions runner, with credentials wiped once
the runner has done its job.

For configuration management and server provisioning, we went with **Ansible**.
I've been using Ansible for over a year and its a pleasure to use due to its
simplicity and vast feature set that can do in five minutes what would take you
thirty! We apply base configuration like setting the time zone, adding SSH keys,
and setting firewall rules before deploying the application itself. Application
deployment consists of copying a production version of our `docker-compose.yaml`
and creating some skeleton directories and files that will be initialized and
maintained by our GitHub Actions workflows.

## Conclusion

This is an exciting time for our team. The app is just getting of its feet and
it feels even better to have a strong foundation to build it on. Being able to
push your code and see green check marks is very reassuring and having those
changes automatically deployed gives my poor sysadmin hands a break from all the
typing. I hope to hone and improve this projects CI/CD and code structure over
time and carry this on into our future projects. One change that was recommended
to me by a colleague before even initializing the repository was splitting the
backend and frontend into separate repos. This seemed excessive to me at the
time but as more and more complexity build in the app I've started to see the
potential benefits.

In any case, we'll see where this project goes and when it is complete how
effective these strategies were at facilitating agile software development!

Questions or comments? [Send an email to us](mailto:cliq@myusc.net) and let us
know if you have a product idea or comments about an existing product.
