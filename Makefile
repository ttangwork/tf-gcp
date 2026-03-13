.PHONY: deploy destroy

deploy:
	./scripts/deploy.sh

destroy:
	DESTROY_FLAG=true ./scripts/deploy.sh
