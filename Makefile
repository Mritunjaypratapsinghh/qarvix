.PHONY: iso clean help docker-build docker-iso tools check

VERBOSE ?= 0
export VERBOSE

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

iso: ## Build Qarvix ISO (requires Void Linux host + root)
	@sudo bash build/build-iso.sh

docker-build: ## Build Docker build environment
	docker build -t qarvix-builder .

docker-iso: docker-build ## Build ISO inside Docker container
	mkdir -p out
	docker run --rm --privileged -v $(PWD)/out:/qarvix/out qarvix-builder

tools: ## Build Rust tools
	cd qarvix-tools && cargo build --release

lint: ## Run all linters
	cd qarvix-tools && cargo fmt --all -- --check
	cd qarvix-tools && cargo clippy --all-targets -- -D warnings
	shellcheck build/build-iso.sh installer/install.sh
	find config/runit -name 'run' -exec shellcheck {} +

test: ## Run tests
	cd qarvix-tools && cargo test

clean: ## Remove build artifacts
	rm -rf out/
	cd qarvix-tools && cargo clean
	@echo "Cleaned."

check: ## Verify project structure
	@echo "Checking project structure..."
	@test -f build/build-iso.sh && echo "  ✓ build script" || echo "  ✗ build script missing"
	@test -f packages/packages.conf && echo "  ✓ package list" || echo "  ✗ package list missing"
	@test -f config/sway/config && echo "  ✓ sway config" || echo "  ✗ sway config missing"
	@test -f installer/install.sh && echo "  ✓ installer" || echo "  ✗ installer missing"
	@test -f branding/os-release && echo "  ✓ branding" || echo "  ✗ branding missing"
	@test -f qarvix-tools/Cargo.toml && echo "  ✓ rust workspace" || echo "  ✗ rust workspace missing"
	@test -f Dockerfile && echo "  ✓ dockerfile" || echo "  ✗ dockerfile missing"
	@echo "Done."
