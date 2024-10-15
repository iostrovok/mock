# Prepare variables
VERSION=`git rev-parse --short HEAD`
CURRENT_BRANCH_NAME= $(shell git rev-parse --abbrev-ref HEAD)
PWD_PATH="$(PWD)"
LIST_GO_TEST=`go list ./... | grep -v /vendor/ | grep -v /internal/ | grep -v /console/ | grep -v /cmd/ | grep -v /development/ | grep -v /protogonzo/`
ROOT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SOURCE_PATH :=TEST_SOURCE_PATH=$(PWD) CURRENT_BRANCH_NAME=$(CURRENT_BRANCH_NAME) GOFLAGS=-ldflags=-extldflags=-Wl,-ld_classic

mod-tidy: ## run mod tidy
	@echo "Run go mod tidy...."
	GO111MODULE=on go mod tidy

mod-action-%: ## run mod with * any value use proxy to repositories
	@echo "Run go mod ${*}...."
	GO111MODULE=on go mod $*
	@echo "Done go mod  ${*}"

mod: mod-tidy mod-action-vendor mod-action-download ## Download all dependencies

test: mod ## start tests
	$(SOURCE_PATH) go test ./...

tests: ## run all tests
	go clean -testcache
	$(SOURCE_PATH) go test -v ./...

tests-new: ## Run tests for all packages exclude some packages
	$(SOURCE_PATH) go test -race $(LIST_GO_TEST) -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html
	rm coverage.out
