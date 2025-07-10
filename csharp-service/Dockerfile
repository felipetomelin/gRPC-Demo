FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 50051

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["GreeterService.csproj", "GreeterService/"]
COPY ["../proto/", "proto/"]
RUN dotnet restore "GreeterService/GreeterService.csproj"
COPY . .
WORKDIR "/src/GreeterService"
RUN dotnet build "GreeterService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "GreeterService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "GreeterService.dll"]
