.PHONY: help install install-mac install-linux bindings test clean

help:
	@echo "Keyboard Shortcuts Manager - Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make install        Install dependencies (auto-detect OS)"
	@echo "  make install-mac    Install macOS dependencies via Homebrew"
	@echo "  make install-linux  Install Linux dependencies via apt"
	@echo "  make bindings       Generate platform-specific configs from abstract spec"
	@echo "  make test           Run basic validation tests"
	@echo "  make clean          Remove generated files"
	@echo ""

install:
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) install-mac; \
	elif [ "$$(uname)" = "Linux" ]; then \
		$(MAKE) install-linux; \
	else \
		echo "Unsupported OS: $$(uname)"; \
		exit 1; \
	fi

install-mac:
	@echo "Installing macOS dependencies..."
	@# Ensure Homebrew is available
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Homebrew not found. Installing..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@# Resolve brew path (Apple Silicon and Intel)
	@BREW_PATH="$$(command -v brew || true)"; \
	if [ -z "$$BREW_PATH" ] && [ -x /opt/homebrew/bin/brew ]; then BREW_PATH=/opt/homebrew/bin/brew; fi; \
	if [ -z "$$BREW_PATH" ] && [ -x /usr/local/bin/brew ]; then BREW_PATH=/usr/local/bin/brew; fi; \
	if [ -z "$$BREW_PATH" ]; then echo "Error: brew not found after install"; exit 1; fi; \
	echo "Using $$BREW_PATH"; \
	if [ -f vendor/Brewfile ]; then \
		"$$BREW_PATH" bundle --no-lock --file=vendor/Brewfile; \
	else \
		echo "Warning: vendor/Brewfile not found. Falling back to Brewfile"; \
		"$$BREW_PATH" bundle --no-lock --file=Brewfile; \
	fi
	@echo "✓ macOS dependencies installed"
	@echo ""
	@echo "Next steps:"
	@echo "  - Run: make bindings"
	@echo "  - Import dist/karabiner-macos.json in Karabiner-Elements"

install-linux:
	@echo "Installing Linux dependencies..."
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: Must run as root (use sudo make install-linux)"; \
		exit 1; \
	fi
	./scripts/install-deps-linux.sh
	@echo ""
	@echo "Next steps:"
	@echo "  - Run: make bindings"
	@echo "  - Run: ./scripts/shortcuts.sh apply"

bindings:
	@echo "Generating platform-specific binding configs..."
	./src/methods/generate-bindings.sh
	@echo ""
	@echo "Generated:"
	@echo "  - dist/xremap-macos.yml (Linux)"
	@echo "  - dist/karabiner-macos.json (macOS)"

test:
	@echo "Running validation tests..."
	@bash -n src/methods/generate-bindings.sh || (echo "✗ generate-bindings.sh syntax error"; exit 1)
	@bash -n scripts/shortcuts.sh || (echo "✗ shortcuts.sh syntax error"; exit 1)
	@bash -n scripts/install-deps-linux.sh || (echo "✗ install-deps-linux.sh syntax error"; exit 1)
	@for script in src/interface/*/*.sh; do \
		bash -n "$$script" || (echo "✗ $$script syntax error"; exit 1); \
	done
	@echo "✓ All scripts have valid syntax"
	@if command -v yq >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then \
		echo "✓ yq and jq installed"; \
	else \
		echo "⚠ Warning: yq or jq not installed (needed for 'make bindings')"; \
	fi

clean:
	@echo "Cleaning generated files..."
	rm -f dist/xremap-macos.yml
	rm -f dist/karabiner-macos.json
	@echo "✓ Cleaned"
