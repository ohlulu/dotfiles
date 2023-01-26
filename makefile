#!make
.DEFAULT_GOAL := all
SELF          := $(MAKE) -f $(MAKEFILE_LIST)
BREWDELEGATOR := $(MAKE) --makefile=.brew/makefile

.PHONY: all 
all: install-brew brew-bundle config-mac install-ohmyzsh  ## [All] install-brew brew-bundle config-mac install-ohmyzsh

.PHONY: install-brew 
install-brew: ## [安裝] homebrew
	@$(SELF) log MESSAGE="Start checking for Homebrew..."
	@if [ "$$(brew doctor)" != "Your system is ready to brew." ]; then \
		echo "brew doesn't instaalled, start installing..."; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@$(SELF) log-success MESSAGE="brew did installed"

.PHONY: brew-bundle
brew-bundle: ## [安裝] brew bundle
	@$(SELF) log MESSAGE="Start brew bundle installing..."
	@brew bundle --file=~/.brew/Brewfile 
	@$(SELF) log-success MESSAGE="brew bundle did installed"

.PHONY: config-mac
config-mac: ## [設定] Mac OS 環境
	@sh ~/.macOS/install.sh

.PHONY: install-ohmyzsh ## [安裝] ohmyzsh
install-ohmyzsh:
	@sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

.PHONY: help h
help h: ## [幫助] 印出所有 makefile target
	@echo -----------------------------------------------------------------------
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make [optinos]\033[36m\033[0m\n"} /^[$$()% 0-9a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo -----------------------------------------------------------------------

### ----------------------- Helpers ----------------------- ###

NC    	= \033[0m
GREEN 	= \033[1;32m

.PHONY: log-success
log-success: 
	@$(SELF) log STYLE="$(GREEN)" MESSAGE="$(MESSAGE) 🥑"

.PHONY: log
log: 
	@printf "[🦁] ${STYLE}$(MESSAGE)${NC}\n"
