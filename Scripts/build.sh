#!/bin/bash
# Build script for DogTV+
# Agent 1: Build System & Project Structure

set -e

# Configuration
SCHEME="DogTVPlus"
WORKSPACE="DogTVPlus.xcworkspace"
CONFIGURATION=${1:-Debug}
PLATFORM=${2:-tvOS}
CLEAN=${3:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏗️  Building DogTV+ - Configuration: $CONFIGURATION, Platform: $PLATFORM${NC}"

# Clean if requested
if [ "$CLEAN" == "true" ]; then
    echo -e "${YELLOW}🧹 Cleaning build directory...${NC}"
    swift package clean
    rm -rf .build
    rm -rf DerivedData
fi

# Resolve dependencies
echo -e "${YELLOW}📦 Resolving dependencies...${NC}"
swift package resolve

# Run SwiftLint
echo -e "${YELLOW}🔍 Running SwiftLint...${NC}"
if command -v swiftlint &> /dev/null; then
    swiftlint lint --config .swiftlint.yml
else
    echo -e "${YELLOW}⚠️  SwiftLint not found, skipping...${NC}"
fi

# Build based on configuration
case $CONFIGURATION in
    "Debug")
        echo -e "${GREEN}🔨 Building Debug configuration...${NC}"
        swift build --configuration debug
        ;;
    "Release")
        echo -e "${GREEN}🔨 Building Release configuration...${NC}"
        swift build --configuration release
        ;;
    "Archive")
        echo -e "${GREEN}📦 Building Archive configuration...${NC}"
        swift build --configuration release
        # Additional archive steps would go here
        ;;
    *)
        echo -e "${RED}❌ Unknown configuration: $CONFIGURATION${NC}"
        exit 1
        ;;
esac

# Run tests if Debug configuration
if [ "$CONFIGURATION" == "Debug" ]; then
    echo -e "${YELLOW}🧪 Running tests...${NC}"
    swift test
fi

echo -e "${GREEN}✅ Build completed successfully!${NC}"