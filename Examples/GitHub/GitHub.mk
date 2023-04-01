MANIFEST_PATH = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: examples_github_xcodeproj
examples_github_xcodeproj:
	@tuist generate --no-open --path $(MANIFEST_PATH)
