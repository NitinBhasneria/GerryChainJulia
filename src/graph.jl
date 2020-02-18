using JSON
using SparseArrays
using LightGraphs
abstract type AbstractGraph end

struct Graph<:AbstractGraph
    num_nodes::Int
    num_edges::Int

    # an adjacency matrix where each entry is the edge id that connects
    # the two nodes.
    adj_matrix::SparseMatrixCSC{Int, Int}

    # source and destination of the edge. the index of these arrays are the
    # edge ids.
    edge_src::Array{Int, 1}
    edge_dst::Array{Int, 1}

    # an Array of Arrays where the neighbors of node `i` are found in an array
    # at index `i`
    node_neighbors::Array{Array{Int64,1},1}

    # the base SimpleGraph, if we need it
    simple_graph::SimpleGraph
end

function Graph(raw_graph::Dict{String, Any},
               nodes_str::AbstractString = "nodes",
               adjacency_str::AbstractString = "adjacency",
               edge_id_str::AbstractString = "id")::Graph

    """ Builds the base Graph object. This is the underlying network of our
        districts, and should never need to be changed.

        Arguments:
            filepath: file path to the .json file that contains the graph. This
                      file is expected to be generated by the `Graph.to_json()`
                      function http://tiny.cc/7ya2jz of the Python implementation
                      of Gerrychain.
    """
    num_nodes = length(raw_graph[nodes_str])

    # Generate the base SimpleGraph.
    simple_graph = SimpleGraph(num_nodes)
    for (index, edges) in enumerate(raw_graph[adjacency_str])
        for edge in edges
            if edge[edge_id_str] + 1 > index
                add_edge!(simple_graph, index, edge[edge_id_str] + 1)
            end
        end
    end

    num_edges = ne(simple_graph)

    edge_src = zeros(Int, num_edges)
    edge_dst = zeros(Int, num_edges)
    node_neighbors = [Int[] for i=1:num_nodes, j=1]

    # populate our own adjacency matrix
    adj_matrix = spzeros(Int, num_nodes, num_nodes)
    for (index, edge) in enumerate(edges(simple_graph))
        adj_matrix[src(edge), dst(edge)] = index
        adj_matrix[dst(edge), src(edge)] = index

        edge_src[index] = src(edge)
        edge_dst[index] = dst(edge)

        push!(node_neighbors[src(edge)], dst(edge))
        push!(node_neighbors[dst(edge)], src(edge))
    end

    return Graph(num_nodes, num_edges, adj_matrix, edge_src, edge_dst,
                 node_neighbors, simple_graph)
end
