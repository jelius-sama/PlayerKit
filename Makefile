# Configuration
PROJECT := PlayerKit.xcodeproj
SCHEME  := PlayerKit
CONFIG  := Debug
SDK     := macosx
DERIVED := build/DerivedData
APP_NAME := PlayerKit.app
INSTALL_DIR := $(HOME)/Applications

.PHONY: help release install index build run clean schemes

help:
	@echo ""
	@echo "make index   → Generate buildServer.json (LSP)"
	@echo "make build   → Build app ($(CONFIG))"
	@echo "make run     → Build & run app (like ▶️ in Xcode)"
	@echo "make clean   → Clean build artifacts"
	@echo "make schemes → List available schemes"
	@echo ""

# SourceKit-LSP
index:
	xcode-build-server config -project $(PROJECT)

install: release
	cp -R $(DERIVED)/Build/Products/Release/$(APP_NAME) $(INSTALL_DIR)

# Release build
release:
	$(MAKE) build CONFIG=Release

# Build
build:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-sdk $(SDK) \
		-derivedDataPath $(DERIVED) \
		build

# Run (Debug)
run: build
	@APP_PATH=$$(find $(DERIVED)/Build/Products/$(CONFIG) -name "*.app" | head -n 1); \
	if [ -z "$$APP_PATH" ]; then \
		echo "❌ App not found"; exit 1; \
	fi; \
	open "$$APP_PATH"

# Clean
clean:
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		clean
	rm -rf $(DERIVED)

# List schemes
schemes:
	xcodebuild \
		-project $(PROJECT) \
		-list
