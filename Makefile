makeGO_BUILD_CMD ?= go build
GO_BUILD_ARGS ?= $(if $(GO_BUILD_LDFLAGS),-ldflags="$(GO_BUILD_LDFLAGS)")
GO_BUILD_LDFLAGS ?=
DOCKER_COMPOSE_CMD ?= docker compose

.SUFFIXES:
.DEFAULT: all

.PHONY: all
all: \
	test \
	gobuild_worker \
	gobuild_webserver \
	temporal_up \

test:
	go test ./...

gobuild_worker:
	docker build -t chatbot --build-arg path=./temporal/workers/chatbot .
gobuild_webserver:
	docker build -t webserver --build-arg path=./webserver .

.PHONY: temporal_up
temporal_up: gobuild_webserver
	$(DOCKER_COMPOSE_CMD) -f local-temporal-server.yaml -p temporal up -d


.PHONY: dev_up
dev_up: temporal_up test gobuild_worker 
	$(DOCKER_COMPOSE_CMD) -f local-workers.yaml -p workers-server up -d

temporal_down:
	$(DOCKER_COMPOSE_CMD) -f local-temporal-server.yaml -p temporal down


dev_down: temporal_down
	$(DOCKER_COMPOSE_CMD) -f local-workers.yaml -p workers-server down 

# Database migration targets
.PHONY: migrate_up migrate_down migrate_list
migrate_up:
	./migrate.sh up

migrate_down:
	@echo "Please specify migration name: make migrate_down MIGRATION=migration_name"

migrate_list:
	./migrate.sh list 
