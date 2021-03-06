
@testset "Recom tests" begin
    graph = BaseGraph(filepath, "population", "assignment")

    @testset "traverse_mst()" begin
        nodes = [1, 2, 3, 4, 5, 6, 7, 8]
        edges = [graph.adj_matrix[1,5], graph.adj_matrix[5,6], graph.adj_matrix[2,6],
                 graph.adj_matrix[2,3], graph.adj_matrix[3,7], graph.adj_matrix[3,4],
                 graph.adj_matrix[4,8]]
        mst = build_mst(graph, BitSet(nodes), BitSet(edges))
        stack = Stack{Int}()
        component_container = BitSet([])
        cut_edge = graph.adj_matrix[2,3]
        component = traverse_mst(mst, 2, 3, stack, component_container)
        @test component == BitSet([1, 2, 5, 6])
        component = traverse_mst(mst, 1, 5, stack, component_container)
        @test component == BitSet([1])
    end
end
