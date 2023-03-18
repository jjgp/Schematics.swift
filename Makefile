.PHONY: bootstrap
bootstrap:
	@$(MAKE) brew
	@$(MAKE) install_tuist
	@$(MAKE) pre-commit-install

.PHONY: brew
brew:
	@brew bundle --no-lock

.PHONY: install_tuist
install_tuist:
	@if ! command -v tuist &> /dev/null; then \
    	curl -Ls https://install.tuist.io | bash; \
	fi

.PHONY: open
open:
	@open Schematics.xcworkspace

.PHONY: pre-commit-install
pre-commit-install:
	@pre-commit install
	@pre-commit install -t post-checkout

.PHONY: tuist_generate
tuist_generate:
	@tuist generate --no-open --path Examples/Reddit
