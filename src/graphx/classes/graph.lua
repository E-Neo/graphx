local class = require "graphx.utils.class"
local utils_copy = require "graphx.utils.copy"

local __init = function (self, attr)
   attr = attr or {}
   self.graph = {}
   self.node = {}
   self.adj = {}
   self.edge = self.adj
   for k, v in pairs(attr) do self.graph[k] = v end
   if self.graph.name == nil then self.graph.name = "" end
end

local __tostring = function (self)
   return self.graph.name
end

local name = function (self, new_name)
   if new_name == nil then return self.graph.name end
   self.graph.name = new_name
end

local add_node = function (self, n, attr)
   attr = attr or {}
   if not self.node[n] then
      self.adj[n] = {}
      self.node[n] = {}
      for k, v in pairs(attr) do self.node[n][k] = v end
   else
      for k, v in pairs(attr) do self.node[n][k] = v end
   end
end

local add_nodes_from = function (self, nodes, have, attr)
   attr = attr or {}
   if have then
      for _, n_d in ipairs(nodes) do
         local n, d = n_d[1], n_d[2] or {}
         if not self.node[n] then
            self.adj[n] = {}
            self.node[n] = {}
            for k, v in pairs(attr) do self.node[n][k] = v end
            for k, v in pairs(d) do self.node[n][k] = v end
         else
            for k, v in pairs(attr) do self.node[n][k] = v end
            for k, v in pairs(d) do self.node[n][k] = v end
         end
      end
   else
      for _, n in ipairs(nodes) do
         if not self.adj[n] then
            self.adj[n] = {}
            self.node[n] = {}
            for k, v in pairs(attr) do self.node[n][k] = v end
         else
            for k, v in pairs(attr) do self.node[n][k] = v end
         end
      end
   end
end

local remove_node = function (self, n)
   assert(self.node[n],
          string.format("The node %s is not in the digraph.", n))
   for u in pairs(self.adj[n]) do
      self.adj[u][n] = nil
   end
   self.adj[n] = nil
   self.node[n] = nil
end

local remove_nodes_from = function (self, nodes)
   for _, n in ipairs(nodes) do
      if self.node[n] then
         for u in pairs(self.adj[n]) do
            self.adj[u][n] = nil
         end
         self.adj[n] = nil
         self.node[n] = nil
      end
   end
end

local nodes = function (self, data, key, default)
   local res = {}
   if data then
      if key == nil then
         for n, d in pairs(self.node) do
            res[#res+1] = {n, d}
         end
      else
         for n, d in pairs(self.node) do
            local di = d[key] or default
            res[#res+1] = {n, di}
         end
      end
   else
      for n in pairs(self.node) do
         res[#res+1] = n
      end
   end
   return res
end

local number_of_nodes = function (self)
   local count = 0
   for _ in pairs(self.node) do count = count + 1 end
   return count
end

local order = number_of_nodes

local has_node = function (self, n)
   return self.node[n] and true or false
end

local add_edge = function (self, u, v, attr)
   attr = attr or {}
   if not self.node[u] then
      self.adj[u] = {}
      self.node[u] = {}
   end
   if not self.node[v] then
      self.adj[v] = {}
      self.node[v] = {}
   end
   local datadict = self.adj[u][v] or {}
   for k, x in pairs(attr) do datadict[k] = x end
   self.adj[u][v] = datadict
   self.adj[v][u] = datadict
end

local add_edges_from = function (self, ebunch, attr)
   attr = attr or {}
   for _, e in ipairs(ebunch) do
      local u, v, d = e[1], e[2], e[3] or {}
      if not self.node[u] then
         self.adj[u] = {}
         self.node[u] = {}
      end
      if not self.node[v] then
         self.adj[v] = {}
         self.node[v] = {}
      end
      local datadict = self.adj[u][v] or {}
      for k, x in pairs(attr) do datadict[k] = x end
      for k, x in pairs(d) do datadict[k] = x end
      self.adj[u][v] = datadict
      self.adj[v][u] = datadict
   end
end

local add_weighted_edges_from = function (self, ebunch, weight, attr)
   local new_ebunch = {}
   weight = weight or "weight"
   for i, e in ipairs(ebunch) do
      new_ebunch[i] = {e[1], e[2], {}}
      new_ebunch[i][3][weight] = e[3]
   end
   self.add_edges_from(self, new_ebunch, attr)
end

local remove_edge = function (self, u, v)
   if not pcall(function ()
         self.adj[u][v] = nil
         self.adj[v][u] = nil
   end) then
      error(string.format("The edge %s-%s is not in the graph.", u, v))
   end
end

local remove_edges_from = function (self, ebunch)
   for _, e in ipairs(ebunch) do
      local u, v = e[1], e[2]
      if self.adj[u] and self.adj[v] then
         self.adj[u][v] = nil
         self.adj[v][u] = nil
      end
   end
end

local has_edge = function (self, u, v)
   return (self.adj[u] and self.adj[u][v]) and true or false
end

local neighbors = function (self, n)
   assert(self.adj[n], string.format("The node %s is not in the digraph.", n))
   return self.adj[n]
end

local edges = function (self, nbunch, data, key, default)
   local res = {}
   local seen = {}
   local node_nbrs
   if not nbunch then
      node_nbrs = self.adj
   else
      node_nbrs = {}
      for _, n in ipairs(nbunch) do
         node_nbrs[n] = self.adj[n]
      end
   end

   if data then
      if key == nil then
         for n, nbrs in pairs(node_nbrs) do
            for nbr, d in pairs(nbrs) do
               if not seen[nbr] then res[#res+1] = {n, nbr, d} end
            end
            seen[n] = true
         end
      else
         for n, nbrs in pairs(node_nbrs) do
            for nbr, d in pairs(nbrs) do
               if not seen[nbr] then
                  local di = d[key] or default
                  res[#res+1] = {n, nbr, di}
               end
            end
            seen[n] = true
         end
      end
   else
      for n, nbrs in pairs(node_nbrs) do
         for nbr in pairs(nbrs) do
            if not seen[nbr] then res[#res+1] = {n, nbr} end
         end
         seen[n] = true
      end
   end
   return res
end

local get_edge_data = function (self, u, v, default)
   return (self.node[u] and self.node[v]) and self.adj[u][v] or default
end

local adjacency = function (self)
   return self.adj
end

local degree = function (self, nbunch, weight)
   if self.node[nbunch] then
      local res = 0
      if weight == nil then
         for _ in pairs(self.adj[nbunch]) do res = res + 1 end
         if self.adj[nbunch][nbunch] then res = res + 1 end
      else
         for _, v in pairs(self.adj[nbunch]) do res = res + (v[weight] or 1) end
         if self.adj[nbunch][nbunch] then
            res = res + (self.adj[nbunch][nbunch][weight] or 1)
         end
      end
      return res
   end

   local res = {}
   local n_nbrs = {}
   if nbunch == nil then
      for n in pairs(self.node) do
         n_nbrs[#n_nbrs+1] = {n, self.adj[n]}
      end
   else
      for _, n in ipairs(nbunch) do
         if self.node[n] then
            n_nbrs[#n_nbrs+1] = {n, self.adj[n]}
         end
      end
   end
   if weight == nil then
      for i, n_nbr in ipairs(n_nbrs) do
         local n = n_nbr[1]
         local d = 0
         for _ in pairs(n_nbr[2]) do d = d + 1 end
         if self.adj[n][n] then d = d + 1 end
         res[i] = {n, d}
      end
   else
      for i, n_nbr in ipairs(n_nbrs) do
         local n = n_nbr[1]
         local d = 0
         for _, v in pairs(n_nbr[2]) do d = d + (v[weight] or 1) end
         if self.adj[n][n] then d = d + (self.adj[n][n][weight] or 1) end
         res[i] = {n, d}
      end
   end
   return res
end

local clear = function (self)
   self.adj = {}
   self.node = {}
   self.graph = {name = ""}
end

local copy = function (self)
   local self_class = self.__class
   local self_metatable = getmetatable(self)
   setmetatable(self, nil)
   self.__class = nil
   local obj = utils_copy(self)
   self.__class = self_class
   setmetatable(self, self_metatable)
   obj.__class = self.__class
   setmetatable(obj, self_metatable)
   return obj
end

local is_multigraph = function ()
   return false
end

local is_directed = function ()
   return false
end

local to_directed = function (self)
   local gx = require "graphx"
   local G = gx.DiGraph()
   G.graph = utils_copy(self.graph)
   G.node = utils_copy(self.node)
   G.succ = utils_copy(self.adj)
   G.adj = G.succ
   G.pred = utils_copy(self.adj)
   return G
end

local to_undirected = function (self)
   return copy(self)
end

local subgraph = function (self, nbunch)
   local node_dict = {}
   for _, n in ipairs(nbunch) do node_dict[n] = true end
   local H = self.__class()
   for n in pairs(node_dict) do
      if self.node[n] then
         H:add_node(n, self.node[n])
         local ebunch = {}
         for v, d in pairs(self.adj[n]) do
            if node_dict[v] then ebunch[#ebunch+1] = {n, v, d} end
         end
         H:add_edges_from(ebunch)
      end
   end
   return H
end

local edge_subgraph = function (self, ebunch)
   local H = self.__class()
   for _, e in ipairs(ebunch) do
      local u, v = e[1], e[2]
      if has_edge(self, u, v) then
         H:add_edge(u, v)
      end
   end
   return H
end

local nodes_with_selfloops = function (self)
   local res = {}
   for n, nbrs in pairs(self.adj) do
      if nbrs[n] then res[#res+1] = n end
   end
   return res
end

local selfloop_edges = function (self, data, key, default)
   local res = {}
   local node_dict = {}
   for n, nbrs in pairs(self.adj) do
      for nbr, d in pairs(nbrs) do
         if n == nbr then node_dict[n] = d end
      end
   end

   if data then
      if key == nil then
         for n, d in pairs(node_dict) do
            res[#res+1] = {n, n, d}
         end
      else
         for n, d in pairs(node_dict) do
            local di = d[key] or default
            res[#res+1] = {n, n, di}
         end
      end
   else
      for n in pairs(node_dict) do
         res[#res+1] = {n, n}
      end
   end
   return res
end

local number_of_selfloops = function (self)
   local res = 0
   for n in pairs(self.adj) do
      if self.adj[n][n] then res = res + 1 end
   end
   return res
end

local size = function (self, weight)
   local degree_list = degree(self, nil, weight)
   local res = 0
   for _, n_d in ipairs(degree_list) do
      res = res + n_d[2]
   end
   return res / 2
end

local number_of_edges = function (self, u, v)
   if u == nil then return size(self) end
   if self.adj[u] and self.adj[u][v] then
      return 1
   else
      return 0
   end
end

local members = {
   __init = __init,
   __tostring = __tostring,
   name = name,
   add_node = add_node,
   add_nodes_from = add_nodes_from,
   remove_node = remove_node,
   remove_nodes_from = remove_nodes_from,
   nodes = nodes,
   number_of_nodes = number_of_nodes,
   order = order,
   has_node = has_node,
   add_edge = add_edge,
   add_edges_from = add_edges_from,
   add_weighted_edges_from = add_weighted_edges_from,
   remove_edge = remove_edge,
   remove_edges_from = remove_edges_from,
   has_edge = has_edge,
   neighbors = neighbors,
   edges = edges,
   get_edge_data = get_edge_data,
   adjacency = adjacency,
   degree = degree,
   clear = clear,
   copy = copy,
   is_multigraph = is_multigraph,
   is_directed = is_directed,
   to_directed = to_directed,
   to_undirected = to_undirected,
   subgraph = subgraph,
   edge_subgraph = edge_subgraph,
   nodes_with_selfloops = nodes_with_selfloops,
   selfloop_edges = selfloop_edges,
   number_of_selfloops = number_of_selfloops,
   size = size,
   number_of_edges = number_of_edges
}

local Graph = class(nil, members)

return Graph
