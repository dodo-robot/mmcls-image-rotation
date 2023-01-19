SHELL=/bin/bash

KUBECONFIG=
MODEL_NAME= 
MINIO= 

KUBECTL=kubectl --kubeconfig=$(KUBECONFIG)
HELM=helm --kubeconfig=$(KUBECONFIG)
MAKE=make
NAMESPACE=triton


# temporary
# CI_ENVIRONMENT_NAME=test

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

	
deploy_models_to_minio:
	minio=ls model  | awk 'NR==1 {print $$1}'
	model_name=$(KUBECTL) describe pods -n ${NAMESPACE} | grep Name.*minio | awk 'NR==1 {print $$2}'
	$(KUBECTL) exec -it $(minio)  -n ${NAMESPACE} -c minio -- /bin/bash -c "mkdir -p altilia_models"
	$(KUBECTL) cp model/$(model_name) $(MINIO):/opt/bitnami/minio-client/altilia_models/  -n ${NAMESPACE} -c minio
	$(KUBECTL) exec -it $(minio) -n ${NAMESPACE} -c minio -- /bin/bash -c "mc config host add minio http://localhost:9000 Altilia.2021 Altilia.2021"
	$(KUBECTL) exec -it $(minio) -n ${NAMESPACE} -c minio -- /bin/bash -c "mc cp --recursive /opt/bitnami/minio-client/altilia_models/ minio/triton/"
	$(KUBECTL) exec -it $(minio) -n ${NAMESPACE} -c minio -- /bin/bash -c "rm -rf /opt/bitnami/minio-client/altilia_models"
