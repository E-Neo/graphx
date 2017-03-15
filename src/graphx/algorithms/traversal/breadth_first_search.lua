local Queue = require "graphx.utils.queue"


local generic_bfs_edges = function (G, source, neighbors)
   local res = {}
   local visited = {}
   visited[source] = true
   local queue = Queue({{source, neighbors(G, source)}})
   while not queue:is_empty() do
      local u_vs = queue:deq()
      local u, vs = u_vs[1], u_vs[2]
      for v in pairs(vs) do
         if not visited[v] then
            visited[v] = true
            res[#res+1] = {u, v}
            queue:enq({v, neighbors(G, v)})
         end
      end
   end
   return res
end

local bfs_edges = function (G, source, reverse)
   local neighbors = (reverse and G:is_directed()) and
      G.predecessors or G.neighbors
   return generic_bfs_edges(G, source, neighbors)
end

local bfs_tree = function (G, source, reverse)
   local gx = require "graphx"
   local T = gx.DiGraph()
   T:add_node(source)
   T:add_edges_from(bfs_edges(G, source, reverse))
   return T
end

local bfs_predecessors = function (G, source)
   local res = {}
   for _, e in pairs(bfs_edges(G, source)) do
      res[#res+1] = {e[2], e[1]}
   end
   return res
end

local bfs_successors = function (G, source)
   local u = source
   local index = 1
   local res = {{u, {}}}
   for _, e in ipairs(bfs_edges(G, source)) do
      if e[1] == u then
         local succ = res[index][2]
         succ[#succ+1] = e[2]
      else
         index = index + 1
         res[index] = {e[1], {e[2]}}
      end
   end
   return res
end

return {
   bfs_edges = bfs_edges,
   bfs_tree = bfs_tree,
   bfs_predecessors = bfs_predecessors,
   bfs_successors = bfs_successors
}
