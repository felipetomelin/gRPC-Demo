using Grpc.Core;
using GreeterService;
using Common;

namespace GreeterService.Services
{
    public class GreeterServiceImpl : Greeter.GreeterBase
    {
        private readonly ILogger<GreeterServiceImpl> _logger;

        public GreeterServiceImpl(ILogger<GreeterServiceImpl> logger)
        {
            _logger = logger;
        }

        public override Task<HelloReply> SayHello(HelloRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"Received request from {request.Name} in {request.Language}");

            var greeting = request.Language.ToLower() switch
            {
                "pt" or "português" => $"Olá, {request.Name}!",
                "en" or "english" => $"Hello, {request.Name}!",
                "es" or "español" => $"¡Hola, {request.Name}!",
                "fr" or "français" => $"Bonjour, {request.Name}!",
                _ => $"Hello, {request.Name}!"
            };

            return Task.FromResult(new HelloReply
            {
                Message = greeting,
                Status = Status.Ok
            });
        }

        public override Task<HelloReply> SayHelloAgain(HelloRequest request, ServerCallContext context)
        {
            _logger.LogInformation($"Received second request from {request.Name}");

            return Task.FromResult(new HelloReply
            {
                Message = $"Hello again, {request.Name}! Nice to see you back!",
                Status = Status.Ok
            });
        }
    }
}
