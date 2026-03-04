ZPLUG_ROOT  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHOVE_URL   := https://github.com/key-amb/shove
SHOVE_DIR   := $(ZPLUG_ROOT)/.gitignore.d/shove
TEST_TARGET ?= test/commands

.DEFAULT_GOAL := help

.PHONY: all install shove test test-all release help

all:

install: ## Install zplug to your machine

shove: # Grab shove from GitHub and grant execution
	@if [ ! -d $(SHOVE_DIR) ]; then \
		git clone $(SHOVE_URL) $(SHOVE_DIR); \
		chmod 755 $(SHOVE_DIR)/bin/shove; \
		fi

test: shove ## Run command-level tests
	ZPLUG_ROOT=$(ZPLUG_ROOT) $(SHOVE_DIR)/bin/shove -r $(TEST_TARGET) -s zsh

test-all: shove ## Run all tests (including stubs)
	ZPLUG_ROOT=$(ZPLUG_ROOT) $(SHOVE_DIR)/bin/shove -r test -s zsh

release: ## Create new GitHub Releases
	@zsh $(ZPLUG_ROOT)/misc/dev/release.zsh

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
