# gRPC Multi-Language Demo

Este projeto demonstra como implementar comunicação gRPC entre três serviços diferentes:
- **C# Greeter Service** - Serviço de saudação em C#/.NET 8
- **Go Calculator Service** - Serviço de calculadora em Go
- **Python Client Service** - Cliente Python que consome os outros dois serviços

## Estrutura do Projeto

```
grpc-demo/
├── proto/                     # Arquivos .proto compartilhados
│   ├── common.proto          # Tipos comuns
│   ├── greeter.proto         # Definição do serviço Greeter
│   └── calculator.proto      # Definição do serviço Calculator
├── csharp-service/           # Serviço C#
│   ├── Services/
│   ├── Program.cs
│   ├── GreeterService.csproj
│   └── Dockerfile
├── go-service/               # Serviço Go
│   ├── main.go
│   ├── go.mod
│   └── Dockerfile
├── python-service/           # Serviço Python
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── scripts/                  # Scripts de automação
│   ├── generate_protos.sh   # Gera stubs para todas as linguagens
│   ├── build_all.sh        # Faz build de todos os serviços
│   └── run_all.sh          # Executa todos os serviços
└── docker-compose.yml       # Orquestração dos serviços
```

## Pré-requisitos

- Docker e Docker Compose
- Git (opcional)

### Para desenvolvimento local:
- .NET 8 SDK
- Go 1.21+
- Python 3.11+
- Protocol Buffers compiler (protoc)

## Como Executar

### Opção 1: Execução Rápida com Docker
```bash
# Clone o projeto
git clone <seu-repositorio>
cd grpc-demo

# Execute tudo automaticamente
./scripts/run_all.sh
```

### Opção 2: Passo a Passo

1. **Gerar stubs gRPC**:
   ```bash
   ./scripts/generate_protos.sh
   ```

2. **Fazer build dos serviços**:
   ```bash
   ./scripts/build_all.sh
   ```

3. **Executar os serviços**:
   ```bash
   docker-compose up -d
   ```

## Serviços

### C# Greeter Service (Porta 50051)
- Implementa saudações em múltiplas linguagens
- Métodos: `SayHello`, `SayHelloAgain`
- Linguagens suportadas: Português, Inglês, Espanhol, Francês

### Go Calculator Service (Porta 50052)
- Implementa operações matemáticas básicas
- Métodos: `Add`, `Subtract`, `Multiply`, `Divide`
- Inclui tratamento de divisão por zero

### Python Client Service (Porta 50053)
- Consome os outros dois serviços
- Demonstra comunicação inter-serviços
- Executa cenários de teste automatizados

## Testando os Serviços

### Logs dos Serviços
```bash
# Ver logs de todos os serviços
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f csharp-service
docker-compose logs -f go-service
docker-compose logs -f python-service
```

### Status dos Serviços
```bash
docker-compose ps
```

### Testando com grpcurl

1. **Instalar grpcurl**:
   ```bash
   # macOS
   brew install grpcurl

   # Linux
   go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
   ```

2. **Testar Greeter Service**:
   ```bash
   grpcurl -plaintext -d '{"name": "João", "language": "pt"}' \
     localhost:50051 greeter.Greeter/SayHello
   ```

3. **Testar Calculator Service**:
   ```bash
   grpcurl -plaintext -d '{"a": 10, "b": 5}' \
     localhost:50052 calculator.Calculator/Add
   ```

## Desenvolvimento

### Adicionando Novos Métodos

1. **Editar arquivos .proto** em `proto/`
2. **Regenerar stubs**: `./scripts/generate_protos.sh`
3. **Implementar métodos** nos serviços respectivos
4. **Rebuild**: `./scripts/build_all.sh`

### Estrutura dos Contratos

Os arquivos `.proto` definem:
- **common.proto**: Tipos compartilhados (Status, Timestamp, Response)
- **greeter.proto**: Serviço de saudação
- **calculator.proto**: Serviço de calculadora

## Arquitetura

```
┌─────────────────┐    gRPC     ┌─────────────────┐
│                 │ ────────→   │                 │
│ Python Client   │             │ C# Greeter      │
│ Service         │             │ Service         │
│ (Port 50053)    │             │ (Port 50051)    │
│                 │             │                 │
└─────────────────┘             └─────────────────┘
         │                               
         │ gRPC                          
         ▼                               
┌─────────────────┐                     
│                 │                     
│ Go Calculator   │                     
│ Service         │                     
│ (Port 50052)    │                     
│                 │                     
└─────────────────┘                     
```

## Parar os Serviços

```bash
docker-compose down
```

## Limpeza

```bash
# Parar e remover containers
docker-compose down

# Remover imagens
docker rmi grpc-demo/csharp-service:latest
docker rmi grpc-demo/go-service:latest
docker rmi grpc-demo/python-service:latest

# Remover rede
docker network rm grpc-demo-network
```

## Conceitos Demonstrados

- **Multi-linguagem**: C#, Go, Python
- **Comunicação gRPC**: Unary RPC
- **Protocol Buffers**: Definição de contratos
- **Docker**: Containerização
- **Service Discovery**: Comunicação entre containers
- **Health Checks**: Monitoramento de saúde dos serviços
- **Geração de Código**: Stubs automáticos

## Próximos Passos

- Implementar streaming RPC
- Adicionar autenticação/autorização
- Implementar circuit breaker
- Adicionar métricas e observabilidade
- Implementar load balancing
