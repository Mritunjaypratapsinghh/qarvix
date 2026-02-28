.PHONY: iso clean help

VERBOSE ?= 0
export VERBOSE

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

iso: ## Build Qarvix ISO
	@sudo bash build/build-iso.sh

clean: ## Remove build artifacts
	@sudo rm -rf out/
	@echo "Cleaned."

check: ## Verify project structure
	@echo "Checking project structure..."
	@test -f build/build-iso.sh && echo "  ✓ build script" || echo "  ✗ build script missing"
	@test -f packages/packages.conf && echo "  ✓ package list" || echo "  ✗ package list missing"
	@test -f config/sway/config && echo "  ✓ sway config" || echo "  ✗ sway config missing"
	@test -f installer/install.sh && echo "  ✓ installer" || echo "  ✗ installer missing"
	@test -f branding/os-release && echo "  ✓ branding" || echo "  ✗ branding missing"
	@echo "Done."
