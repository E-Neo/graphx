local Stack = require "graphx.utils.stack"


local get_unvisited = function (G, n, visited)
   for nbr in pairs(G:neighbors(n)) do
      if not visited[nbr] then
         return nbr
      end
   end
   return nil
end

local dfs_edges = function (G, source)
   local res = {}
   local nodes = source and {source} or G:nodes()
   local visited = {}
   for _, start in ipairs(nodes) do
      if not visited[start] then
         visited[start] = true
         local stack = Stack({start})
         while not stack:is_empty() do
            local u = stack.data[stack.sp]
            local v = get_unvisited(G, u, visited)
            if v == nil then
               stack:pop()
            else
               visited[v] = true
               stack:push(v)
               res[#res+1] = {u, v}
            end
         end
      end
   end
   return res
end

local dfs_tree = function (G, source)
   local gx = require "graphx"
   local T = gx.DiGraph()
   if source then
      T:add_node(source)
   else
      T:add_nodes_from(G:nodes())
   end
   T:add_edges_from(dfs_edges(G, source))
   return T
end

local dfs_predecessors = function (G, source)
   local res = {}
   for _, e in ipairs(dfs_edges(G, source)) do
      res[e[2]] = e[1]
   end
   return res
end

local dfs_successors = function (G, source)
   local res = {}
   for _, e in ipairs(dfs_edges(G, source)) do
      local succ = res[e[1]]
      succ = succ and succ or {}
      succ[#succ+1] = e[2]
      res[e[1]] = succ
   end
   return res
end

local dfs_labeled_edges = function (G, source)
   local res = {}
   local nodes = source and {source} or G:nodes()
   local visited = {}
   for _, start in ipairs(nodes) do
      if not visited[start] then
         visited[start] = true
         res[#res+1] = {start, start, "forward"}
         local tmp = {}
         for k in pairs(G:neighbors(start)) do tmp[k] = true end
         local stack = Stack({{start, tmp}})
         while not stack:is_empty() do
            local u_adj = stack.data[stack.sp]
            local u, adj = u_adj[1], u_adj[2]
            local v = next(adj)
            if v == nil then
               stack:pop()
               res[#res+1] = stack:is_empty() and {u, u, "reverse"} or
                  {stack.data[stack.sp][1], u, "reverse"}
            elseif visited[v] then
               res[#res+1] = {u, v, "nontree"}
               adj[v] = nil
            else
               res[#res+1] = {u, v, "forward"}
               visited[v] = true
               tmp = {}
               for k in pairs(G:neighbors(v)) do tmp[k] = true end
               stack:push({v, tmp})
               adj[v] = nil
            end
         end
      end
   end
   return res
end

local dfs_preorder_nodes = function (G, source)
   local res = {}
   for _, e in pairs(dfs_labeled_edges(G, source)) do
      if e[3] == "forward" then res[#res+1] = e[2] end
   end
   return res
end

local dfs_postorder_nodes = function (G, source)
   local res = {}
   for _, e in pairs(dfs_labeled_edges(G, source)) do
      if e[3] == "reverse" then res[#res+1] = e[2] end
   end
   return res
end

return {
   dfs_edges = dfs_edges,
   dfs_tree = dfs_tree,
   dfs_predecessors = dfs_predecessors,
   dfs_successors = dfs_successors,
   dfs_preorder_nodes = dfs_preorder_nodes,
   dfs_postorder_nodes = dfs_postorder_nodes,
   dfs_labeled_edges = dfs_labeled_edges
}
