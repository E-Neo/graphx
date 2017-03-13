local gx = require "graphx"

describe("DiGraph", function ()
            it("Graph()", function ()
                  local G = gx.DiGraph({author="E-Neo"})
                  assert.are.equal("E-Neo", G.graph.author)
                  assert.are.equal("", G.graph.name)
                  assert.are.equal(G.adj, G.succ)
            end)

            it("add_node", function ()
                  local G = gx.DiGraph()
                  G:add_node(1, {color="red"})
                  local expected_node = {{color="red"}}
                  local expected_succ = {{}}
                  local expected_pred = {{}}
                  assert.are.same(expected_node, G.node)
                  assert.are.same(expected_succ, G.succ)
                  assert.are.same(expected_pred, G.pred)
                  G:add_node(1, {color="blue", size=10})
                  assert.are.equal("blue", G.node[1]["color"])
                  assert.are.equal(10, G.node[1]["size"])
            end)

            it("add_nodes_from", function ()
                  local G = gx.DiGraph()
                  G:add_nodes_from({1, 2})
                  assert.are.same({{}, {}}, G.node)
                  assert.are.same({{}, {}}, G.succ)
                  assert.are.same({{}, {}}, G.pred)
                  G:add_nodes_from({1, 3}, nil, {color="green"})
                  assert.are.equal("green", G.node[1]["color"])
                  assert.are.equal("green", G.node[3]["color"])
                  G:add_nodes_from({{1, {color="red"}}, {4}}, true)
                  assert.are.equal("red", G.node[1]["color"])
            end)

            it("remove_node", function ()
                  local G = gx.DiGraph()
                  assert.has_error(function () G:remove_node(false) end,
                     "The node false is not in the digraph.")
                  G:add_edges_from({{1, 2}, {2, 3}, {3, 1}})
                  G:remove_node(1)
                  assert.are.same({}, G.pred[2])
                  assert.are.same({}, G.succ[3])
                  assert.are.equal(nil, G.succ[1])
                  assert.are.equal(nil, G.node[1])
            end)

            it("remove_nodes_from", function ()
                  local G = gx.DiGraph()
                  G:add_edges_from({{1, 2}, {2, 3}, {3, 1}})
                  G:remove_nodes_from({1, 2, 5})
                  assert.are.same({nil, nil, {}}, G.node)
                  assert.are.same({nil, nil, {}}, G.succ)
                  assert.are.same({nil, nil, {}}, G.pred)
            end)

            it("add_edge", function ()
                  local G = gx.DiGraph()
                  G:add_edge(1, 2)
                  local expected_node = {{}, {}}
                  local expected_succ = {{nil, {}}, {}}
                  local expected_pred = {{}, {{}}}
                  assert.are.same(expected_node, G.node)
                  assert.are.same(expected_succ, G.succ)
                  assert.are.same(expected_pred, G.pred)
                  G:add_edge(1, 2, {weight = 10})
                  assert.are.equal(10, G.succ[1][2]["weight"])
                  assert.are.equal(G.succ[1][2], G.pred[2][1])
            end)

            it("add_edges_from", function ()
                  local G = gx.DiGraph()
                  G:add_edges_from({{1, 2}, {2, 3}})
                  local expected_node = {{}, {}, {}}
                  local expected_succ = {{nil, {}}, {nil, nil, {}}, {}}
                  local expected_pred = {{}, {{}}, {nil, {}}}
                  assert.are.same(expected_node, G.node)
                  assert.are.same(expected_succ, G.succ)
                  assert.are.same(expected_pred, G.pred)
                  G:add_edges_from({{1, 2, {weight = 10}}, {3, 1}}, {weight = 5})
                  assert.are.equal(10, G.succ[1][2]["weight"])
                  assert.are.equal(5, G.succ[3][1]["weight"])
                  assert.are.equal(G.succ[1][2], G.pred[2][1])
            end)

            it("remove_edge", function ()
                  local G = gx.DiGraph()
                  assert.has_error(function () G:remove_edge(1, 2) end,
                     "The edge 1-2 is not in the graph.")
                  G:add_edge(true, false)
                  G:remove_edge(true, false)
                  assert.are.same({}, G.succ[true])
                  assert.are.same({}, G.pred[false])
                  G:add_edge(1, 1)
                  G:remove_edge(1, 1)
                  assert.are.same({}, G.succ[1])
                  assert.are.same({}, G.pred[1])
            end)

            it("remove_edges_from", function ()
                  local G = gx.DiGraph()
                  G:add_edges_from({{1, 2}, {2, 3}})
                  G:remove_edges_from({{1, 2}, {2, 1}})
                  assert.are.same({{}, {nil, nil, {}}, {}}, G.succ)
                  assert.are.same({{}, {}, {nil, {}}}, G.pred)
            end)

            it("has_successor has_predecessor", function ()
                  local G = gx.DiGraph()
                  G:add_edges_from({{1, 2}, {2, 3}})
                  assert.is_true(G:has_successor(1, 2))
                  assert.is_true(G:has_predecessor(3, 2))
                  assert.is_false(G:has_successor(2, 1))
                  assert.is_false(G:has_successor(4, 1))
                  assert.is_false(G:has_predecessor(1, 3))
                  assert.is_false(G:has_predecessor(4, 3))
            end)

            it("successors predecessors neighbors", function ()
                  local G = gx.DiGraph()
                  G:add_edge(1, 2)
                  G:add_edge(1, 3)
                  assert.is_equal(G.successors, G.neighbors)
                  assert.has_error(function () G:successors(4) end,
                     "The node 4 is not in the digraph.")
                  assert.has_error(function () G:predecessors(4) end,
                     "The node 4 is not in the digraph.")
                  assert.are.same({nil, {}, {}}, G:successors(1))
                  assert.are.same({{}}, G:predecessors(2))
            end)

            it("edges out_edges in_edges", function ()
                  local G = gx.DiGraph()
                  assert.are.equal(G.edges, G.out_edges)
                  G:add_edge(1, 2, {weight = 10, length = 9})
                  assert.are.same({{1, 2}}, G:edges())
                  assert.are.same({{1, 2}}, G:in_edges())
                  assert.are.same({{1, 2, {weight = 10, length = 9}}},
                     G:edges(nil, true))
                  assert.are.same({{1, 2, {weight = 10, length = 9}}},
                     G:in_edges(nil, true))
                  assert.are.same({{1, 2, 9}},
                     G:edges(nil, true, "length"))
                  assert.are.same({{1, 2, 9}},
                     G:in_edges(nil, true, "length"))
                  G:add_edge(3, 4)
                  assert.are.same({{3, 4, "red"}},
                     G:edges({2, 3, 4, 5}, true, "color", "red"))
                  assert.are.same({{3, 4, "red"}},
                     G:in_edges({1, 3, 4, 5}, true, "color", "red"))
            end)

            it("clear", function ()
                  local G = gx.DiGraph()
                  G:add_edges_from({{1, 2}, {2, 3}})
                  G:clear()
                  assert.are.same({}, G.succ)
                  assert.are.same({}, G.pred)
                  assert.are.same({}, G.node)
                  assert.are.same({name=""}, G.graph)
            end)

            it("is_multigraph is_directed", function ()
                  local G = gx.DiGraph()
                  assert.is_false(G:is_multigraph())
                  assert.is_true(G:is_directed())
            end)
end)
