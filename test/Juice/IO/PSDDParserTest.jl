using Test
using .Juice
import .Juice.IO: 
   parse_comment_line, parse_lc_header_line, parse_lc_literal_line, parse_literal_line, parse_lc_decision_line, parse_bias_line, parse_lc_file, 
   CircuitFormatLine, BiasLine, DecisionLine, WeightedLiteralLine, CircuitHeaderLine, CircuitCommentLine, LCElement, CircuitFormatLines


@testset "Load a small PSDD and test methods" begin
   file = "circuits/little_4var.psdd"
   prob_circuit = load_prob_circuit(file);
   @test prob_circuit isa ProbΔ

   # Testing number of nodes and parameters
   @test  9 == num_parameters(prob_circuit)
   @test 20 == size(prob_circuit)[1]
   
   # Testing Read Parameters
   EPS = 1e-7
   @test abs(prob_circuit[13].log_thetas[1] - (-1.6094379124341003)) < EPS
   @test abs(prob_circuit[13].log_thetas[2] - (-1.2039728043259361)) < EPS
   @test abs(prob_circuit[13].log_thetas[3] - (-0.916290731874155)) < EPS
   @test abs(prob_circuit[13].log_thetas[4] - (-2.3025850929940455)) < EPS

   @test abs(prob_circuit[18].log_thetas[1] - (-2.3025850929940455)) < EPS
   @test abs(prob_circuit[18].log_thetas[2] - (-2.3025850929940455)) < EPS
   @test abs(prob_circuit[18].log_thetas[3] - (-2.3025850929940455)) < EPS
   @test abs(prob_circuit[18].log_thetas[4] - (-0.35667494393873245)) < EPS

   @test abs(prob_circuit[20].log_thetas[1] - (0.0)) < EPS
end

psdd_files = ["circuits/little_4var.psdd", "circuits/msnbc-yitao-a.psdd", "circuits/msnbc-yitao-b.psdd", "circuits/msnbc-yitao-c.psdd", "circuits/msnbc-yitao-d.psdd", "circuits/msnbc-yitao-e.psdd", "circuits/mnist-antonio.psdd"]

@testset "Test parameter integrity of loaded PSDDs" begin
   for psdd_file in psdd_files
      @test check_parameter_integrity(load_prob_circuit(psdd_file))
   end
end

@testset "Test parameter integrity of loaded structured PSDDs" begin
   circuit, vtree = load_struct_prob_circuit(
      "circuits/little_4var.psdd", "circuits/little_4var.vtree")
   @test check_parameter_integrity(circuit)
   @test vtree isa Vtree
   # no other combinations of vtree and psdd are in this repo?
   # @test check_parameter_integrity(load_struct_prob_circuit(
   #          "circuits/mnist-antonio.psdd", "circuits/balanced.vtree"))
end
