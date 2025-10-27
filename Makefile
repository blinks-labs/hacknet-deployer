PROJECT_NAME := hackaton
HOSTS_FILE ?= hosts_hackathon.ini
BOOTSTRAP_NODE_INDEX ?= 12
NUM_PROXIES ?= 4

define extract_hosts
$(if $(strip $(1)),$(shell awk '/ansible_host=/ {print $$2}' $(1) | cut -d'=' -f2),)
endef

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


stop: ## Stop compose services
	@echo "Stopping ${PROJECT_NAME} services..."
	docker compose -f docker-compose.yml down

pull: ## Pull latest changes
	@echo "Pulling latest changes for ${PROJECT_NAME}..."
	git pull origin
	docker compose -f docker-compose.yml pull
	$(MAKE) stop

deploy_p2p: pull ## Deploy optimum p2p via docker
	@echo "Deploying ${PROJECT_NAME} optimum p2p..."
	docker compose -f docker-compose.yml up -d --no-deps optimum-node

deploy_proxy: pull ## Deploy optimum proxy via docker
	@echo "Deploying ${PROJECT_NAME} optimum proxy..."
	docker compose -f docker-compose.yml up -d --no-deps proxy

deploy: ## Deploy clusters (usage: make deploy)
	ansible-playbook -i ./nodes.ini deploy_clusters.yml -u optimumuser --ask-pass --ask-become-pass 


check_hackathon_hosts: ## Check connectivity to hackathon hosts (requires HOSTS_FILE=)
	@echo "Checking connectivity to hackathon hosts..."
	@HOSTS="$(call extract_hosts,$(HOSTS_FILE))"; \
	echo "================= Checking hosts from $(HOSTS_FILE) ================="; \
	for host in $$HOSTS; do \
		echo -n "$$host: "; \
		if timeout 5 nc -z $$host 22 2>/dev/null; then \
			echo "SSH port open"; \
		else \
			echo "SSH port closed/unreachable"; \
		fi; \
	done

upload_config: ## Upload configuration file to servers (usage: make upload_config)
	ansible-playbook -i ./nodes.ini upload_config.yml -u optimumuser --ask-pass --ask-become-pass 

stop_and_remove_containers: ## Stop and remove containers (usage: make stop_and_remove_containers)
	ansible-playbook -i ./nodes.ini stop_and_remove_containers.yml -u optimumuser --ask-pass --ask-become-pass
	
.DEFAULT_GOAL := help
.PHONY: help check_hackathon_hosts upload_config deploy stop_and_remove_containers
