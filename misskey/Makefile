SHELL := bash
STACK_NAME = misskey
PREFIX = misskey
MISSKEY_SERVICE_NAME = misskey
export misskey_version = misskey/misskey:12.49.1@sha256:7a6801170d60c773405f139ba41af8ce00f450224eda5bfb76c524d2940a5867

exit:
	exit 0

ls:
	docker stack services ${STACK_NAME}
stats:
	docker stats $$(docker ps --filter label=com.docker.stack.namespace=${STACK_NAME} --format='{{.ID}}')
ps:
	docker ps --filter label=com.docker.stack.namespace=${STACK_NAME}

${PREFIX}-init:
	mkdir -p data/pg data/redis data/files

${PREFIX}-stop:
	docker service scale ${STACK_NAME}_${MISSKEY_SERVICE_NAME}=0
${PREFIX}-scale:
	docker service scale ${STACK_NAME}_${MISSKEY_SERVICE_NAME}=1

${PREFIX}-update:
	docker stack deploy -c docker-compose.yml ${STACK_NAME}
${PREFIX}-restart:
	docker service update --force ${STACK_NAME}_misskey
${PREFIX}-logs:
	docker service logs -f --since 0m ${STACK_NAME}_${MISSKEY_SERVICE_NAME}
${PREFIX}-down:
	docker stack rm ${STACK_NAME}

${PREFIX}-ls:
	docker stack services ${STACK_NAME}

${PREFIX}-upgrade:
	make ${PREFIX}-stop
	docker run --rm -ti \
		-v /work/misskey/config:/misskey/.config/:rslave \
		-v /work/misskey/files:/misskey/files:rslave \
		--net ${STACK_NAME}_default \
		${misskey_version} \
		npm run migrate
