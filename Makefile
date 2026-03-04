DOCKER_COMPOSE = docker compose

install:
	poetry install

run:
	poetry run python main.py

clean:
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -exec rm -rf {} +

up:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d
	$(DOCKER_COMPOSE) logs -f

deploy:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

logs:
	$(DOCKER_COMPOSE) logs -f

restart:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) up -d
	$(DOCKER_COMPOSE) logs -f

docker-clean:
	$(DOCKER_COMPOSE) down --rmi all --volumes --remove-orphans
	docker system prune -f

proto:
	poetry run python -m grpc_tools.protoc -I proto --python_out=proto --grpc_python_out=proto proto/whisper.proto
	sed -i.bak 's/^import whisper_pb2/from proto import whisper_pb2/' proto/whisper_pb2_grpc.py && rm -f proto/whisper_pb2_grpc.py.bak

.PHONY: install run clean up deploy down restart docker-clean proto
