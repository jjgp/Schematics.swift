.PHONY: bootstrap
bootstrap:
	@$(MAKE) brew
	@$(MAKE) install_tuist
	@$(MAKE) pre-commit-install
	@$(MAKE) tuist_generate

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

.PHONY: test
test: PLATFORM ?= "iOS Simulator,OS=16.2,name=iPhone 14"
test: TEST_TARGETS ?= FoundationSchema GitHub ReactiveSchema UnidirectionalSchema
test:
	@for target in $(TEST_TARGETS);  do \
		xcodebuild test -workspace Schematics.xcworkspace -scheme $$target -destination platform=$(PLATFORM); \
	done

.PHONY: tuist_generate
tuist_generate:
	@tuist generate --no-open --path Examples/GitHub
