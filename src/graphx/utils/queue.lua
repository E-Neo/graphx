local class = require "graphx.utils.class"


local __init = function (self, data)
   data = data or {}
   self.data = data
   self.first = 1
   self.last = #data
end

local is_empty = function (self)
   return self.first > self.last
end

local enq = function (self, item)
   local last = self.last + 1
   self.last = last
   self.data[last] = item
end

local deq = function (self)
   local first = self.first
   assert(first <= self.last, "empty queue")
   local item = self.data[first]
   self.data[first] = nil
   self.first = first + 1
   return item
end

local members = {
   __init = __init,
   is_empty = is_empty,
   enq = enq,
   deq = deq
}

local Queue = class(nil, members)

return Queue
