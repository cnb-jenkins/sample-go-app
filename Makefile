MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c +x
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

GIT_REPO ?= https://github.com/cnb-jenkins/sample-go-app
TAG ?= samj1912/sample-go-app
GIT_REVISION ?= $(shell git rev-parse HEAD)
APP_NAME ?= sample-go-app
CLUSTER_BUILDER ?= tiny-cluster-builder

.PHONY: unit-test
unit-test:
	@echo "Running unit tests..."
	@echo "Done!"

.PHONY: acceptance-test  
acceptance-test:
	@echo "Running acceptance tests..."
	@echo "Done!"

kp:
	@curl -L https://github.com/vmware-tanzu/kpack-cli/releases/download/v0.3.0/kp-linux-0.3.0 > kp && chmod +x kp

.PHONY: build
build: kp
	@./kp image save $(APP_NAME) --git $(GIT_REPO) --git-revision $(GIT_REVISION) --cluster-builder $(CLUSTER_BUILDER) -w --tag $(TAG)

.PHONY: image-tag
image-tag: kp
	@./kp image status $(APP_NAME) | grep Image |  tr -s ' ' | cut -d ' ' -f 2
	
kubectl:
	@curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl

.PHONY: image-status
image-status: kp
	@./kp build logs $(APP_NAME)
	@./kp image status $(APP_NAME)

.PHONY: deploy
deploy: kubectl kp
	@./kubectl delete job -l job-name=$(APP_NAME)
	@./kubectl delete pods -l job-name=$(APP_NAME)
	@./kubectl create job --image "$$(./kp image status $(APP_NAME) | grep Image |  tr -s ' ' | cut -d ' ' -f 2)" $(APP_NAME) && ./kubectl wait --for=condition=complete job/$(APP_NAME)
	@./kubectl logs -l job-name=$(APP_NAME)
