local class = require "graphx.utils.class"
local Graph = require "graphx.classes.graph"


local __init = function (self, attr)
   attr = attr or {}
   self.graph = {}
   self.adj = {}
   self.node = {}
   self.pred = {}
   self.succ = self.adj
   for k, v in pairs(attr) do self.graph[k] = v end
   if self.graph.name == nil then self.graph.name = "" end
end

local add_node = function (self, n, attr)
   attr = attr or {}
   if not self.succ[n] then
      self.succ[n] = {}
      self.pred[n] = {}
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
         if not self.succ[n] then
            self.succ[n] = {}
            self.pred[n] = {}
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
         if not self.succ[n] then
            self.succ[n] = {}
            self.pred[n] = {}
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
   for v in pairs(self.succ[n]) do
      self.pred[v][n] = nil
   end
   self.succ[n] = nil
   for u in pairs(self.pred[n]) do
      self.succ[u][n] = nil
   end
   self.pred[n] = nil
   self.node[n] = nil
end

local remove_nodes_from = function (self, nbunch)
   for _, n in ipairs(nbunch) do
      if self.node[n] then
         for v in pairs(self.succ[n]) do
            self.pred[v][n] = nil
         end
         self.succ[n] = nil
         for u in pairs(self.pred[n]) do
            self.succ[u][n] = nil
         end
         self.pred[n] = nil
         self.node[n] = nil
      end
   end
end

local add_edge = function (self, u, v, attr)
   attr = attr or {}
   if not self.succ[u] then
      self.succ[u] = {}
      self.pred[u] = {}
      self.node[u] = {}
   end
   if not self.succ[v] then
      self.succ[v] = {}
      self.pred[v] = {}
      self.node[v] = {}
   end
   local datadict = self.succ[u][v] or {}
   for k, x in pairs(attr) do datadict[k] = x end
   self.succ[u][v] = datadict
   self.pred[v][u] = datadict
end

local add_edges_from = function (self, ebunch, attr)
   attr = attr or {}
   for _, e in ipairs(ebunch) do
      local u, v, d = e[1], e[2], e[3] or {}
      if not self.succ[u] then
         self.succ[u] = {}
         self.pred[u] = {}
         self.node[u] = {}
      end
      if not self.succ[v] then
         self.succ[v] = {}
         self.pred[v] = {}
         self.node[v] = {}
      end
      local datadict = self.succ[u][v] or {}
      for k, x in pairs(attr) do datadict[k] = x end
      for k, x in pairs(d) do datadict[k] = x end
      self.succ[u][v] = datadict
      self.pred[v][u] = datadict
   end
end

local remove_edge = function (self, u, v)
   if not pcall(function ()
         self.succ[u][v] = nil
         self.pred[v][u] = nil
   end) then
      error(string.format("The edge %s-%s is not in the graph.", u, v))
   end
end

local remove_edges_from = function (self, ebunch)
   for _, e in ipairs(ebunch) do
      local u, v = e[1], e[2]
      if self.succ[u] and self.succ[v] then
         self.succ[u][v] = nil
         self.pred[v][u] = nil
      end
   end
end

local has_successor = function (self, u, v)
   return self.succ[u] and self.succ[u][v] and true or false
end

local has_predecessor = function (self, u, v)
   return self.pred[u] and self.pred[u][v] and true or false
end

local successors = function (self, n)
   assert(self.succ[n], string.format("The node %s is not in the digraph.", n))
   return self.succ[n]
end

local predecessors = function (self, n)
   assert(self.succ[n], string.format("The node %s is not in the digraph.", n))
   return self.pred[n]
end

local neighbors = successors

local edges = function (self, nbunch, data, key, default)
   local res = {}
   local u_vs
   if not nbunch then
      u_vs = self.adj
   else
      u_vs = {}
      for _, n in ipairs(nbunch) do
         u_vs[n] = self.adj[n]
      end
   end

   if data then
      if key == nil then
         for u, vs in pairs(u_vs) do
            for v, d in pairs(vs) do
               res[#res+1] = {u, v, d}
            end
         end
      else
         for u, vs in pairs(u_vs) do
            for v, d in pairs(vs) do
               local di = d[key] or default
               res[#res+1] = {u, v, di}
            end
         end
      end
   else
      for u, vs in pairs(u_vs) do
         for v in pairs(vs) do
            res[#res+1] = {u, v}
         end
      end
   end
   return res
end

local out_edges = edges

local in_edges = function (self, nbunch, data, key, default)
   local res = {}
   local v_us
   if not nbunch then
      v_us = self.pred
   else
      v_us = {}
      for _, n in ipairs(nbunch) do
         v_us[n] = self.pred[n]
      end
   end

   if data then
      if key == nil then
         for v, us in pairs(v_us) do
            for u, d in pairs(us) do
               res[#res+1] = {u, v, d}
            end
         end
      else
         for v, us in pairs(v_us) do
            for u, d in pairs(us) do
               local di = d[key] or default
               res[#res+1] = {u, v, di}
            end
         end
      end
   else
      for v, us in pairs(v_us) do
         for u in pairs(us) do
            res[#res+1] = {u, v}
         end
      end
   end
   return res
end

local degree = function (self, nbunch, weight)
   if self.node[nbunch] then
      local res = 0
      local succ = self.succ[nbunch]
      local pred = self.pred[nbunch]
      if weight == nil then
         for _ in pairs(succ) do res = res + 1 end
         for _ in pairs(pred) do res = res + 1 end
      else
         for _, v in pairs(succ) do res = res + (v[weight] or 1) end
         for _, v in pairs(pred) do res = res + (v[weight] or 1) end
      end
      return res
   end

   local res = {}
   local n_succ_preds = {}
   if nbunch == nil then
      for n in pairs(self.node) do
         n_succ_preds[#n_succ_preds+1] = {n, self.succ[n], self.pred[n]}
      end
   else
      for _, n in ipairs(nbunch) do
         if self.node[n] then
            n_succ_preds[#n_succ_preds+1] = {n, self.succ[n], self.pred[n]}
         end
      end
   end
   if weight == nil then
      for i, n_succ_pred in ipairs(n_succ_preds) do
         local n = n_succ_pred[1]
         local d = 0
         for _ in pairs(n_succ_pred[2]) do d = d + 1 end
         for _ in pairs(n_succ_pred[3]) do d = d + 1 end
         res[i] = {n, d}
      end
   else
      for i, n_succ_pred in ipairs(n_succ_preds) do
         local n = n_succ_pred[1]
         local d = 0
         for _, v in pairs(n_succ_pred[2]) do d = d + (v[weight] or 1) end
         for _, v in pairs(n_succ_pred[3]) do d = d + (v[weight] or 1) end
         res[i] = {n, d}
      end
   end
   return res
end

local in_degree = function (self, nbunch, weight)
   if self.node[nbunch] then
      local res = 0
      local pred = self.pred[nbunch]
      if weight == nil then
         for _ in pairs(pred) do res = res + 1 end
         return res
      end
      for _, v in pairs(pred) do res = res + (v[weight] or 1) end
      return res
   end

   local res = {}
   local n_preds = {}
   if nbunch == nil then
      for n in pairs(self.node) do
         n_preds[#n_preds+1] = {n, self.pred[n]}
      end
   else
      for _, n in ipairs(nbunch) do
         if self.node[n] then
            n_preds[#n_preds+1] = {n, self.pred[n]}
         end
      end
   end
   if weight == nil then
      for i, n_pred in ipairs(n_preds) do
         local n = n_pred[1]
         local d = 0
         for _ in pairs(n_pred[2]) do d = d + 1 end
         res[i] = {n, d}
      end
   else
      for i, n_pred in ipairs(n_preds) do
         local n = n_pred[1]
         local d = 0
         for _, u in pairs(n_pred[2]) do d = d + (u[weight] or 1) end
         res[i] = {n, d}
      end
   end
   return res
end

local out_degree = function (self, nbunch, weight)
   if self.node[nbunch] then
      local res = 0
      local succ = self.succ[nbunch]
      if weight == nil then
         for _ in pairs(succ) do res = res + 1 end
         return res
      end
      for _, v in pairs(succ) do res = res + (v[weight] or 1) end
      return res
   end

   local res = {}
   local n_succs = {}
   if nbunch == nil then
      for n in pairs(self.node) do
         n_succs[#n_succs+1] = {n, self.succ[n]}
      end
   else
      for _, n in ipairs(nbunch) do
         if self.node[n] then
            n_succs[#n_succs+1] = {n, self.succ[n]}
         end
      end
   end
   if weight == nil then
      for i, n_succ in ipairs(n_succs) do
         local n = n_succ[1]
         local d = 0
         for _ in pairs(n_succ[2]) do d = d + 1 end
         res[i] = {n, d}
      end
   else
      for i, n_succ in ipairs(n_succs) do
         local n = n_succ[1]
         local d = 0
         for _, v in pairs(n_succ[2]) do d = d + (v[weight] or 1) end
         res[i] = {n, d}
      end
   end
   return res
end

local clear = function (self)
   self.succ = {}
   self.pred = {}
   self.node = {}
   self.graph = {name = ""}
end

local is_multigraph = function ()
   return false
end

local is_directed = function ()
   return true
end

local members = {
   __init = __init,
   add_node = add_node,
   add_nodes_from = add_nodes_from,
   remove_node = remove_node,
   remove_nodes_from = remove_nodes_from,
   add_edge = add_edge,
   add_edges_from = add_edges_from,
   remove_edge = remove_edge,
   remove_edges_from = remove_edges_from,
   has_successor = has_successor,
   has_predecessor = has_predecessor,
   successors = successors,
   predecessors = predecessors,
   neighbors = neighbors,
   edges = edges,
   out_edges = out_edges,
   in_edges = in_edges,
   degree = degree,
   in_degree = in_degree,
   out_degree = out_degree,
   clear = clear,
   is_multigraph = is_multigraph,
   is_directed = is_directed
}

local DiGraph = class(Graph, members)

return DiGraph
