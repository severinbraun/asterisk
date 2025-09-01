REGISTRY ?= ghcr.io
OWNER    ?= $(shell echo $$GITHUB_REPOSITORY_OWNER)
APP      ?= asterisk
TAG      ?= $(shell git rev-parse --short HEAD)
IMG      := $(REGISTRY)/$(OWNER)/$(APP):$(TAG)

build:
	docker buildx build -f containers/$(APP)/Dockerfile -t $(IMG) --load .

push:
	docker buildx build -f containers/$(APP)/Dockerfile -t $(IMG) --push .

run:
	OWNER=$(OWNER) TAG=$(TAG) docker compose -f deploy/compose.yaml up --build

.PHONY: build push run
