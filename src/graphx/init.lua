local Graph = require "graphx.classes.graph"
local DiGraph = require "graphx.classes.digraph"

local breadth_first_search = require "graphx.algorithms.traversal.breadth_first_search"
local depth_first_search = require "graphx.algorithms.traversal.depth_first_search"

return {
   Graph = Graph,
   DiGraph = DiGraph,

   bfs_edges = breadth_first_search.bfs_edges,
   bfs_tree = breadth_first_search.bfs_tree,
   bfs_predecessors = breadth_first_search.bfs_predecessors,
   bfs_successors = breadth_first_search.bfs_successors,

   dfs_edges = depth_first_search.dfs_edges,
   dfs_tree = depth_first_search.dfs_tree,
   dfs_predecessors = depth_first_search.dfs_predecessors,
   dfs_successors = depth_first_search.dfs_successors,
   dfs_preorder_nodes = depth_first_search.dfs_preorder_nodes,
   dfs_postorder_nodes = depth_first_search.dfs_postorder_nodes,
   dfs_labeled_edges = depth_first_search.dfs_labeled_edges
}
