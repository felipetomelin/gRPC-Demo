#!/bin/bash

echo "Starting all gRPC services..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASE_DIR"

echo -e "${YELLOW}Starting services from directory: $BASE_DIR${NC}"

# Check if images exist
if ! docker images | grep -q "grpc-demo"; then
    echo -e "${YELLOW}Docker images not found. Building first...${NC}"
    ./scripts/build_all.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}Build failed!${NC}"
        exit 1
    fi
fi

# Start services
echo -e "${GREEN}Starting services with docker-compose...${NC}"
docker-compose up -d

# Wait a bit for services to start
sleep 5

# Show running services
echo -e "${GREEN}Services status:${NC}"
docker-compose ps

echo -e "${GREEN}Services started successfully!${NC}"
echo -e "${YELLOW}Services are running on:${NC}"
echo -e "  - C# Greeter Service: localhost:50051"
echo -e "  - Go Calculator Service: localhost:50052"
echo -e "  - Python Client Service: localhost:50053"
echo ""
echo -e "${YELLOW}To view logs, run:${NC}"
echo -e "  docker-compose logs -f"
echo ""
echo -e "${YELLOW}To stop services, run:${NC}"
echo -e "  docker-compose down"
