.PHONY: bootstrap
bootstrap:
	@$(MAKE) brew
	@$(MAKE) install_tuist

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
