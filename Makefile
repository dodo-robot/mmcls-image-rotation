SHELL=/bin/bash

KUBECTL=kubectl --kubeconfig=$(KUBECONFIG)
HELM=helm --kubeconfig=$(KUBECONFIG)
MAKE=make
NAMESPACE=triton

# temporary
# CI_ENVIRONMENT_NAME=test

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

get_model_name:
	ls model  | awk 'NR==1 {print $$1}'

get_minio_pod:
	$(KUBECTL) describe pods -n ${NAMESPACE} | grep Name.*minio | awk 'NR==1 {print $$2}' 

load_model_to_pod: 
	$(KUBECTL) exec -it $(MINIO)  -n ${NAMESPACE} -c minio -- /bin/bash -c "mkdir -p altilia_models"

deploy_models_to_minio: 
	$(KUBECTL) exec -it $(MINIO) -n ${NAMESPACE} -c minio -- /bin/bash -c "mc config host add minio http://localhost:9000 Altilia.2021 Altilia.2021"
	$(KUBECTL) exec -it $(MINIO) -n ${NAMESPACE} -c minio -- /bin/bash -c "mc cp --recursive /opt/bitnami/minio-client/altilia_models/ minio/triton/"

delete_model_from_pod: 
	$(KUBECTL) exec -it $(MINIO) -n ${NAMESPACE} -c minio -- /bin/bash -c "rm -rf /opt/bitnami/minio-client/altilia_models"

