.DEFAULT_GOAL: build-all

############
# DEFAULTS #
############

KIND_IMAGE           ?= kindest/node:$(K8S_VERSION)
KIND_NAME            ?= kind
USE_CONFIG           ?= standard

#########
# TOOLS #
#########

TOOLS_DIR                          := $(PWD)/.tools
KIND                               := $(TOOLS_DIR)/kind
KIND_VERSION                       := v0.18.0
KUTTL                              := $(TOOLS_DIR)/kubectl-kuttl
KUTTL_VERSION                      := v0.0.0-20230108220859-ef8d83c89156
TOOLS                              := $(KIND) $(KUTTL)

$(KIND):
	@echo Install kind... >&2
	@GOBIN=$(TOOLS_DIR) go install sigs.k8s.io/kind@$(KIND_VERSION)

$(KUTTL):
	@echo Install kuttl... >&2
	@GOBIN=$(TOOLS_DIR) go install github.com/kyverno/kuttl/cmd/kubectl-kuttl@$(KUTTL_VERSION)

.PHONY: install-tools
install-tools: $(TOOLS)

.PHONY: clean-tools
clean-tools: 
	@echo Clean tools... >&2
	@rm -rf $(TOOLS_DIR)

###############
# KUTTL TESTS #
###############

.PHONY: test-kuttl
test-kuttl: $(KUTTL) ## Run kuttl tests
	@echo Running kuttl tests... >&2
	@$(KUTTL) test --start-kind=false ./e2e/t01-n4k-installation
# @$(KUTTL) test --config kuttl-test.yaml

.PHONY: test-kuttl-upgrade
test-kuttl-upgrade: $(KUTTL) ## Run kuttl tests
	@echo Running kuttl tests... >&2
	@$(KUTTL) test --config kuttl-test-upgrade.yaml

.PHONY: kuttl-test-all
kuttl-test-all: test-kuttl test-kuttl-upgrade

## Create kind cluster
.PHONY: kind-create-cluster
kind-create-cluster: $(KIND) 
	@echo Create kind cluster... >&2
	@$(KIND) create cluster --name $(KIND_NAME) --image $(KIND_IMAGE)

## Delete kind cluster
.PHONY: kind-delete-cluster
kind-delete-cluster: $(KIND) 
	@echo Delete kind cluster... >&2
	@$(KIND) delete cluster --name $(KIND_NAME)
