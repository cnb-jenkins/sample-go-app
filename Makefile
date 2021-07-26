MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c +x
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

GIT_REPO ?= https://github.com/cnb-jenkins/sample-app
TAG ?= samj1912/sample-app
GIT_REVISION ?= $(shell git rev-parse HEAD)

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
	@./kp image save demo --git $(GIT_REPO) --git-revision $(GIT_REVISION) --cluster-builder my-cluster-builder -w --tag $(TAG)

.PHONY: image-tag
image-tag: kp
	@./kp image status demo | grep Image |  tr -s ' ' | cut -d ' ' -f 2
	
kubectl:
	@curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl

.PHONY: image-status
image-status: kp
	@./kp build logs demo
	@./kp image status demo

.PHONY: deploy
deploy: kubectl kp
	@./kubectl delete job -l job-name=hello-world
	@./kubectl delete pods -l job-name=hello-world
	@./kubectl create job --image "$$(./kp image status demo | grep Image |  tr -s ' ' | cut -d ' ' -f 2)" hello-world && ./kubectl wait --for=condition=complete job/hello-world
	@./kubectl logs -l job-name=hello-world
