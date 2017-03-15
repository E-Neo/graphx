local Graph = require "graphx.classes.graph"
local DiGraph = require "graphx.classes.digraph"

local breadth_first_search = require "graphx.algorithms.traversal.breadth_first_search"


return {
   Graph = Graph,
   DiGraph = DiGraph,

   bfs_edges = breadth_first_search.bfs_edges,
   bfs_tree = breadth_first_search.bfs_tree,
   bfs_predecessors = breadth_first_search.bfs_predecessors,
   bfs_successors = breadth_first_search.bfs_successors
}
