package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	pb "github.com/grpc-demo/go-service/proto"
)

const (
	port = ":50052"
)

type calculatorServer struct {
	pb.UnimplementedCalculatorServer
}

func (s *calculatorServer) Add(ctx context.Context, req *pb.CalculateRequest) (*pb.CalculateResponse, error) {
	log.Printf("Received Add request: %v + %v", req.A, req.B)

	result := req.A + req.B
	return &pb.CalculateResponse{
		Result:  result,
		Status:  pb.Status_OK,
		Message: "Addition completed successfully",
	}, nil
}

func (s *calculatorServer) Subtract(ctx context.Context, req *pb.CalculateRequest) (*pb.CalculateResponse, error) {
	log.Printf("Received Subtract request: %v - %v", req.A, req.B)

	result := req.A - req.B
	return &pb.CalculateResponse{
		Result:  result,
		Status:  pb.Status_OK,
		Message: "Subtraction completed successfully",
	}, nil
}

func (s *calculatorServer) Multiply(ctx context.Context, req *pb.CalculateRequest) (*pb.CalculateResponse, error) {
	log.Printf("Received Multiply request: %v * %v", req.A, req.B)

	result := req.A * req.B
	return &pb.CalculateResponse{
		Result:  result,
		Status:  pb.Status_OK,
		Message: "Multiplication completed successfully",
	}, nil
}

func (s *calculatorServer) Divide(ctx context.Context, req *pb.CalculateRequest) (*pb.CalculateResponse, error) {
	log.Printf("Received Divide request: %v / %v", req.A, req.B)

	if req.B == 0 {
		return &pb.CalculateResponse{
			Result:  0,
			Status:  pb.Status_ERROR,
			Message: "Division by zero is not allowed",
		}, nil
	}

	result := req.A / req.B
	return &pb.CalculateResponse{
		Result:  result,
		Status:  pb.Status_OK,
		Message: "Division completed successfully",
	}, nil
}

func main() {
	lis, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterCalculatorServer(s, &calculatorServer{})

	// Register reflection service on gRPC server
	reflection.Register(s)

	log.Printf("Calculator server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
