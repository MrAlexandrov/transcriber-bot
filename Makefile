DOCKER_COMPOSE         = docker compose
DOCKER_COMPOSE_WHISPER = docker compose -f docker-compose.whisper.yml

.PHONY: install
install:
	poetry install

.PHONY: run
run:
	poetry run python main.py

.PHONY: clean
clean:
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -exec rm -rf {} +

# --- Whisper standalone service ---

.PHONY: whisper-up
whisper-up:
	$(DOCKER_COMPOSE_WHISPER) up -d --build

.PHONY: whisper-down
whisper-down:
	$(DOCKER_COMPOSE_WHISPER) down

.PHONY: whisper-logs
whisper-logs:
	$(DOCKER_COMPOSE_WHISPER) logs -f

.PHONY: whisper-deploy
whisper-deploy:
	$(DOCKER_COMPOSE_WHISPER) up -d --build --no-cache

# --- Bot (requires whisper-up first) ---

.PHONY: up
up:
	$(DOCKER_COMPOSE) up -d --build

.PHONY: down
down:
	$(DOCKER_COMPOSE) down

.PHONY: logs
logs:
	$(DOCKER_COMPOSE) logs -f

.PHONY: restart
restart:
	$(DOCKER_COMPOSE) restart

.PHONY: deploy
deploy:
	$(DOCKER_COMPOSE) up -d --build --no-cache

# Regenerate Python gRPC stubs from proto/whisper.proto
.PHONY: proto
proto:
	poetry run python -m grpc_tools.protoc \
		-I . \
		--python_out=. \
		--grpc_python_out=. \
		--mypy_out=. \
		--mypy_grpc_out=. \
		proto/whisper.proto

# Regenerate Go gRPC stubs into bot/gen/whisper/
# Requires: protoc, protoc-gen-go, protoc-gen-go-grpc
# Install plugins: go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
#                  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
.PHONY: proto-go
proto-go:
	mkdir -p bot/gen/whisper
	protoc -I proto \
		--go_out=bot/gen/whisper --go_opt=paths=source_relative \
		--go-grpc_out=bot/gen/whisper --go-grpc_opt=paths=source_relative \
		proto/whisper.proto
