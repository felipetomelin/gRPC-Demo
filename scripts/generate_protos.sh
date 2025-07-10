#!/bin/bash

echo "Generating gRPC stubs for all languages..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}Error: protoc compiler not found. Please install Protocol Buffers compiler.${NC}"
    exit 1
fi

# Base directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROTO_DIR="$BASE_DIR/proto"

echo -e "${YELLOW}Base directory: $BASE_DIR${NC}"
echo -e "${YELLOW}Proto directory: $PROTO_DIR${NC}"

# Generate for C#
echo -e "${GREEN}Generating C# stubs...${NC}"
cd "$BASE_DIR/csharp-service"
# C# stubs are generated automatically by MSBuild

# Generate for Go
echo -e "${GREEN}Generating Go stubs...${NC}"
cd "$BASE_DIR/go-service"
mkdir -p proto

# Install Go protobuf plugins if not installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo "Installing protoc-gen-go..."
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo "Installing protoc-gen-go-grpc..."
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# Generate Go protobuf files
protoc --go_out=. --go_opt=paths=source_relative \
    --go-grpc_out=. --go-grpc_opt=paths=source_relative \
    -I="$PROTO_DIR" \
    "$PROTO_DIR"/*.proto

# Generate for Python
echo -e "${GREEN}Generating Python stubs...${NC}"
cd "$BASE_DIR/python-service"

# Install grpcio-tools if not installed
if ! python -c "import grpc_tools" &> /dev/null; then
    echo "Installing grpcio-tools..."
    pip install grpcio-tools
fi

# Generate Python protobuf files
python -m grpc_tools.protoc -I="$PROTO_DIR" --python_out=. --grpc_python_out=. "$PROTO_DIR"/*.proto

echo -e "${GREEN}All stubs generated successfully!${NC}"
