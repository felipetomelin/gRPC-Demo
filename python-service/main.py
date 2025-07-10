import grpc
import time
import asyncio
from concurrent import futures
import logging

# Import generated proto files
import greeter_pb2
import greeter_pb2_grpc
import calculator_pb2
import calculator_pb2_grpc
import common_pb2

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ClientService:
    """Service that acts as a client to both C# and Go services"""

    def __init__(self):
        # Initialize gRPC channels
        self.greeter_channel = grpc.insecure_channel('csharp-service:50051')
        self.calculator_channel = grpc.insecure_channel('go-service:50052')

        # Create stubs
        self.greeter_stub = greeter_pb2_grpc.GreeterStub(self.greeter_channel)
        self.calculator_stub = calculator_pb2_grpc.CalculatorStub(self.calculator_channel)

    def test_greeter_service(self, name="World", language="en"):
        """Test the C# Greeter service"""
        try:
            logger.info(f"Testing Greeter service with name: {name}, language: {language}")

            # Call SayHello
            request = greeter_pb2.HelloRequest(name=name, language=language)
            response = self.greeter_stub.SayHello(request)

            logger.info(f"Greeter response: {response.message}")

            # Call SayHelloAgain
            response2 = self.greeter_stub.SayHelloAgain(request)
            logger.info(f"Greeter again response: {response2.message}")

            return response.message, response2.message

        except grpc.RpcError as e:
            logger.error(f"gRPC error calling greeter service: {e}")
            return None, None

    def test_calculator_service(self, a, b):
        """Test the Go Calculator service"""
        try:
            logger.info(f"Testing Calculator service with a={a}, b={b}")

            # Test all operations
            operations = [
                ("Add", self.calculator_stub.Add),
                ("Subtract", self.calculator_stub.Subtract),
                ("Multiply", self.calculator_stub.Multiply),
                ("Divide", self.calculator_stub.Divide)
            ]

            results = {}

            for op_name, op_func in operations:
                request = calculator_pb2.CalculateRequest(a=a, b=b, operation=op_name)
                response = op_func(request)

                logger.info(f"{op_name} result: {response.result} - {response.message}")
                results[op_name] = response.result

            return results

        except grpc.RpcError as e:
            logger.error(f"gRPC error calling calculator service: {e}")
            return {}

    def close(self):
        """Close gRPC channels"""
        self.greeter_channel.close()
        self.calculator_channel.close()

def wait_for_services():
    """Wait for other services to be ready"""
    services = [
        ("csharp-service", 50051),
        ("go-service", 50052)
    ]

    for service_name, port in services:
        logger.info(f"Waiting for {service_name} to be ready...")
        max_retries = 30
        retry_count = 0

        while retry_count < max_retries:
            try:
                channel = grpc.insecure_channel(f'{service_name}:{port}')
                grpc.channel_ready_future(channel).result(timeout=5)
                channel.close()
                logger.info(f"{service_name} is ready!")
                break
            except grpc.FutureTimeoutError:
                retry_count += 1
                logger.info(f"Retrying connection to {service_name}... ({retry_count}/{max_retries})")
                time.sleep(2)

        if retry_count >= max_retries:
            logger.error(f"Failed to connect to {service_name} after {max_retries} attempts")
            return False

    return True

def main():
    """Main function to demonstrate inter-service communication"""
    logger.info("Starting Python Client Service...")

    # Wait for other services to be ready
    if not wait_for_services():
        logger.error("Failed to connect to required services")
        return

    # Create client service
    client = ClientService()

    try:
        # Test scenarios
        test_scenarios = [
            {"name": "Alice", "language": "en"},
            {"name": "João", "language": "pt"},
            {"name": "Carlos", "language": "es"},
            {"name": "Marie", "language": "fr"}
        ]

        logger.info("\n=== Testing Greeter Service (C#) ===")
        for scenario in test_scenarios:
            client.test_greeter_service(scenario["name"], scenario["language"])
            time.sleep(1)

        logger.info("\n=== Testing Calculator Service (Go) ===")
        calc_scenarios = [
            (10, 5),
            (7, 3),
            (15, 0),  # Division by zero test
            (100, 25)
        ]

        for a, b in calc_scenarios:
            results = client.test_calculator_service(a, b)
            time.sleep(1)

        logger.info("\n=== Demo completed successfully! ===")

        # Keep the service running
        logger.info("Python service will keep running to demonstrate multi-service communication...")
        logger.info("Press Ctrl+C to stop")

        # Run continuous demo
        while True:
            time.sleep(10)
            # Demonstrate continuous communication
            client.test_greeter_service("Demo User", "en")
            client.test_calculator_service(42, 8)

    except KeyboardInterrupt:
        logger.info("Shutting down...")
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    main()
