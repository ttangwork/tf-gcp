KYVERNO_VERSION ?= v1.13.4
MANIFESTS_DIR := manifests
INGRESS_MODE ?= gateway

.PHONY: deploy destroy install-kyverno namespaces platform teams-alpha teams-beta

deploy: install-kyverno namespaces platform teams-alpha teams-beta
	@echo "Deployment complete"

install-kyverno:
	@if ! kubectl get namespace kyverno >/dev/null 2>&1; then \
		echo "Installing Kyverno $(KYVERNO_VERSION)"; \
		kubectl create -f "https://github.com/kyverno/kyverno/releases/download/$(KYVERNO_VERSION)/install.yaml"; \
		echo "Waiting for Kyverno to be ready"; \
		kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=kyverno -n kyverno --timeout=120s; \
	fi

namespaces:
	@echo "Creating namespaces"
	kubectl apply -f $(MANIFESTS_DIR)/namespaces/

platform:
	@if [ "$(INGRESS_MODE)" != "gateway" ] && [ "$(INGRESS_MODE)" != "ingress" ]; then \
		echo "Error: INGRESS_MODE must be 'gateway' or 'ingress' (got '$(INGRESS_MODE)')"; \
		exit 1; \
	fi
	@echo "Deploying platform resources (mode: $(INGRESS_MODE))"
	kubectl apply -f $(MANIFESTS_DIR)/platform/$(INGRESS_MODE).yaml
	kubectl apply -f $(MANIFESTS_DIR)/platform/kyverno-policies.yaml

teams-alpha:
	@echo "Deploying alpha resources"
	@for f in $(MANIFESTS_DIR)/teams/alpha/*.yaml; do \
		if [ "$(INGRESS_MODE)" = "ingress" ] && echo "$$f" | grep -q "http-route"; then \
			echo "Skipping $$f (ingress mode)"; \
			continue; \
		fi; \
		kubectl apply -f "$$f"; \
	done

teams-beta:
	@echo "Deploying beta resources"
	@for f in $(MANIFESTS_DIR)/teams/beta/*.yaml; do \
		if [ "$(INGRESS_MODE)" = "ingress" ] && echo "$$f" | grep -q "http-route"; then \
			echo "Skipping $$f (ingress mode)"; \
			continue; \
		fi; \
		kubectl apply -f "$$f"; \
	done

destroy:
	@echo "Deleting all resources"
	kubectl delete namespace alpha beta --ignore-not-found
	kubectl delete namespace platform --ignore-not-found
	kubectl delete -f $(MANIFESTS_DIR)/platform/kyverno-policies.yaml --ignore-not-found
	kubectl delete -f "https://github.com/kyverno/kyverno/releases/download/$(KYVERNO_VERSION)/install.yaml" --ignore-not-found
