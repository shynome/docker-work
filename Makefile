SHELL := bash
STACK_NAME = main

exit:
	exit 0

ls:
	docker stack services ${STACK_NAME}
stats:
	docker stats $$(docker ps --filter label=com.docker.stack.namespace=${STACK_NAME} --format='{{.ID}}')
ps:
	docker ps --filter label=com.docker.stack.namespace=${STACK_NAME}

swarm-init:
	docker swarm init --advertise-addr 127.0.0.1

update:
	docker stack deploy -c docker-compose.yml ${STACK_NAME}

proxy-logs:
	docker service logs -f --since 0m ${STACK_NAME}_proxy

proxy-restart:
	docker service update --force ${STACK_NAME}_proxy

# proxy-reload:
# 	docker stack deploy -c docker-compose.yml ${STACK_NAME}
