#!/bin/bash

echo "Building all gRPC services..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

echo -e "${YELLOW}Building from directory: $BASE_DIR${NC}"

# Generate protobuf stubs first
echo -e "${GREEN}Step 1: Generating protobuf stubs...${NC}"
./scripts/generate_protos.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to generate protobuf stubs${NC}"
fi

# Build with docker-compose
echo -e "${GREEN}Step 2: Building Docker images...${NC}"
docker-compose build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}All services built successfully!${NC}"
    echo -e "${YELLOW}Run './scripts/run_all.sh' to start all services${NC}"
else
    echo -e "${RED}Build failed!${NC}"
fi
