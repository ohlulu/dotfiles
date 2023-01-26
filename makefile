#!make
.DEFAULT_GOAL := all
SELF          := $(MAKE) -f $(MAKEFILE_LIST)
BREWDELEGATOR := $(MAKE) --makefile=.brew/makefile

.PHONY: all
all: install-brew

.PHONY: install-brew congifure-macOS install-ohmyzsh
install-brew: 
	@$(SELF) log MESSAGE="Start checking for Homebrew..."
	@if [ "$$(brew doctor)" != "Your system is ready to brew." ]; then \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@$(SELF) log-success MESSAGE="brew did installed"
	@$(SELF) log MESSAGE="Start brew bundle installing..."
	@brew bundle --file=~/.brew/Brewfile > /dev/null 2>&1
	@$(SELF) log-success MESSAGE="brew bundle did installed"

.PHONY: congifure-macOS
congifure-macOS:
	@sh ~/.macOS/install.sh

.PHONY: install-ohmyzsh
install-ohmyzsh:
	@sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


### ----------------------- Helpers ----------------------- ###

NC    	= \033[0m
GREEN 	= \033[1;32m

.PHONY: log-success
log-success: 
	@$(SELF) log STYLE="$(GREEN)" MESSAGE="$(MESSAGE) 🥑"

.PHONY: log
log: 
	@printf "[🦁] ${STYLE}$(MESSAGE)${NC}\n"
