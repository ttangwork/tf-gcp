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
	kubectl apply -f $(MANIFESTS_DIR)/teams/alpha/

teams-beta:
	@echo "Deploying beta resources"
	kubectl apply -f $(MANIFESTS_DIR)/teams/beta/

destroy:
	@echo "Deleting team namespaces and platform resources"
	kubectl delete -f $(MANIFESTS_DIR)/teams/alpha/ --ignore-not-found
	kubectl delete -f $(MANIFESTS_DIR)/teams/beta/ --ignore-not-found
	kubectl delete -f $(MANIFESTS_DIR)/platform/ --ignore-not-found
	kubectl delete -f $(MANIFESTS_DIR)/namespaces/ --ignore-not-found
