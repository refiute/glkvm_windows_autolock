SHELL := /bin/bash

REPO_DIR := $(shell pwd)
PY       := /usr/bin/env python3
PIP      := pip3
SCRIPT   := $(REPO_DIR)/lock_windows.py
ENV_FILE := $(REPO_DIR)/.env
LOG_FILE := $(REPO_DIR)/autolock.log
CRON_TAG  := \# glkvm-autolock
CRON_LINE := 55 21 * * * cd $(REPO_DIR) && $(PY) $(SCRIPT) >> $(LOG_FILE) 2>&1 $(CRON_TAG)

.PHONY: install deps env cron test uninstall help

help:
	@echo "Targets:"
	@echo "  make install    - install deps, prompt password, register cron (21:55 daily)"
	@echo "  make test       - run once now (will lock the connected Windows immediately)"
	@echo "  make uninstall  - remove cron entry and .env"

install: deps env cron
	@echo
	@echo "Setup complete."
	@echo "  Cron line: $(CRON_LINE)"
	@echo "  Run 'make test' to verify (this WILL lock the connected Windows)."

deps:
	$(PIP) install --upgrade pikvm-lib

env:
	@if [ -f "$(ENV_FILE)" ]; then \
	  echo "$(ENV_FILE) already exists; keeping current password."; \
	else \
	  printf 'GLKVM (PiKVM admin) password: '; \
	  stty -echo; \
	  IFS= read -r pw; \
	  stty echo; \
	  echo; \
	  if [ -z "$$pw" ]; then \
	    echo "ERROR: empty password" >&2; exit 1; \
	  fi; \
	  umask 077; \
	  printf 'GLKVM_PASSWORD=%s\n' "$$pw" > "$(ENV_FILE)"; \
	  chmod 600 "$(ENV_FILE)"; \
	  echo "Created $(ENV_FILE) (mode 0600)."; \
	fi

cron:
	@( crontab -l 2>/dev/null | grep -v '# glkvm-autolock'; \
	   echo '$(CRON_LINE)' ) | crontab -
	@echo "Installed cron entry. Current crontab:"
	@crontab -l | grep glkvm-autolock

test:
	@echo "WARNING: this will lock the connected Windows machine NOW."
	$(PY) $(SCRIPT)

uninstall:
	-@( crontab -l 2>/dev/null | grep -v '# glkvm-autolock' ) | crontab - ; \
	  echo "Removed cron entry (if it existed)."
	-@rm -f "$(ENV_FILE)" && echo "Removed $(ENV_FILE)."
	@echo "Note: pikvm-lib is left installed. To remove: $(PIP) uninstall -y pikvm-lib"
