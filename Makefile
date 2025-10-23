PROJECT_NAME := hackaton

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

generate-key: ## Generate P2P identity (if missing)
	@mkdir -p ./$(KEY_DIR)
	@if [ ! -f "./$(KEY_DIR)/p2p.key" ]; then \
		echo "Generating new P2P identity..."; \
		./optimump2p/keygen/p2p-keygen -dir $(KEY_DIR) .; \
		echo  "P2P identity in $(KEY_DIR)/p2p.key"; \
	else \
		echo "P2P identity already exists at `pwd`/$(KEY_DIR)/p2p.key"; \
	fi

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

.PHONY: help stop pull deploy_p2p deploy_proxy
.DEFAULT_GOAL := help
