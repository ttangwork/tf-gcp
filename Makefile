KYVERNO_VERSION ?= v1.13.4
MANIFESTS_DIR := manifests

GREEN := \033[32m
RESET := \033[0m

.PHONY: deploy destroy install-kyverno namespaces platform teams-alpha teams-beta

deploy: install-kyverno namespaces platform teams-alpha teams-beta
	@echo "$(GREEN)Deployment complete$(RESET)"

install-kyverno:
	@if ! kubectl get namespace kyverno >/dev/null 2>&1; then \
		echo "$(GREEN)Installing Kyverno $(KYVERNO_VERSION)$(RESET)"; \
		kubectl create -f "https://github.com/kyverno/kyverno/releases/download/$(KYVERNO_VERSION)/install.yaml"; \
		echo "$(GREEN)Waiting for Kyverno to be ready$(RESET)"; \
		kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=kyverno -n kyverno --timeout=120s; \
	fi

namespaces:
	@echo "$(GREEN)Creating namespaces$(RESET)"
	kubectl apply -f $(MANIFESTS_DIR)/namespaces/

platform:
	@echo "$(GREEN)Deploying platform resources$(RESET)"
	kubectl apply -f $(MANIFESTS_DIR)/platform/

teams-alpha:
	@echo "$(GREEN)Deploying team alpha resources$(RESET)"
	kubectl apply -f $(MANIFESTS_DIR)/teams/alpha/

teams-beta:
	@echo "$(GREEN)Deploying team beta resources$(RESET)"
	kubectl apply -f $(MANIFESTS_DIR)/teams/beta/

destroy:
	@echo "$(GREEN)Deleting all resources$(RESET)"
	kubectl delete namespace alpha beta --ignore-not-found
	kubectl delete namespace platform --ignore-not-found
	kubectl delete -f $(MANIFESTS_DIR)/platform/ --ignore-not-found
	kubectl delete -f "https://github.com/kyverno/kyverno/releases/download/$(KYVERNO_VERSION)/install.yaml" --ignore-not-found
