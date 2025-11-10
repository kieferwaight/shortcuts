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
	brew bundle install
	@echo "✓ macOS dependencies installed"
	@echo ""
	@echo "Next steps:"
	@echo "  - Run: make bindings"
	@echo "  - Import macos/karabiner-macos.json in Karabiner-Elements"

install-linux:
	@echo "Installing Linux dependencies..."
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "Error: Must run as root (use sudo make install-linux)"; \
		exit 1; \
	fi
	./install-deps-linux.sh
	@echo ""
	@echo "Next steps:"
	@echo "  - Run: make bindings"
	@echo "  - Run: ./shortcuts.sh apply"

bindings:
	@echo "Generating platform-specific binding configs..."
	./scripts/generate-bindings.sh
	@echo ""
	@echo "Generated:"
	@echo "  - keyboard-mapping/xremap-macos.yml (Linux)"
	@echo "  - macos/karabiner-macos.json (macOS)"

test:
	@echo "Running validation tests..."
	@bash -n scripts/generate-bindings.sh || (echo "✗ generate-bindings.sh syntax error"; exit 1)
	@bash -n shortcuts.sh || (echo "✗ shortcuts.sh syntax error"; exit 1)
	@bash -n install-deps-linux.sh || (echo "✗ install-deps-linux.sh syntax error"; exit 1)
	@for script in keyboard-mapping/*.sh gnome-shortcuts/*.sh; do \
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
	rm -f keyboard-mapping/xremap-macos.yml
	rm -f macos/karabiner-macos.json
	@echo "✓ Cleaned"
