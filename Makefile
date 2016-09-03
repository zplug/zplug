ZPLUG_ROOT  := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
SHOVE_URL   := https://github.com/key-amb/shove
SHOVE_DIR   := $(ZPLUG_ROOT)/.gitignore.d/shove
TEST_TARGET ?= test
ACCESS_TOKEN := $$GITHUB_ZPLUG_MAN_ACCESS_TOKEN

.DEFAULT_GOAL := help

.PHONY: all install shove test release help

all:

install: ## Install zplug to your machine

shove: # Grab shove from GitHub and grant execution
	@if [ ! -d $(SHOVE_DIR) ]; then \
		git clone $(SHOVE_URL) $(SHOVE_DIR); \
		chmod 755 $(SHOVE_DIR)/bin/shove; \
		fi

test: shove ## Unit test for zplug
	ZPLUG_ROOT=$(ZPLUG_ROOT) $(SHOVE_DIR)/bin/shove -r $(TEST_TARGET) -s zsh

release: ## Create new GitHub Releases
	curl --data \
		'{ \
		"tag_name": "'$$_ZPLUG_VERSION'", \
		"target_commitish": "master", \
		"name": "'$$_ZPLUG_VERSION'", \
		"body": "Release of version '$$_ZPLUG_VERSION'", \
		"draft": false, \
		"prerelease": false \
		}' \
		"https://api.github.com/repos/zplug/zplug/releases?access_token=$(ACCESS_TOKEN)"

patch:
	git tag -a $$_ZPLUG_VERSION -m $$_ZPLUG_VERSION
	git push origin $$_ZPLUG_VERSION

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
