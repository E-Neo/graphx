local class = require "graphx.utils.class"


local __init = function (self, data)
   data = data or {}
   self.data = data
   self.sp = #data
end

local is_empty = function (self)
   return self.sp == 0
end

local push = function (self, item)
   local sp = self.sp + 1
   self.sp = sp
   self.data[sp] = item
end

local pop = function (self)
   local sp = self.sp
   assert(sp > 0, "empty stack")
   local item = self.data[sp]
   self.data[sp] = nil
   self.sp = sp - 1
   return item
end

local members = {
   __init = __init,
   is_empty = is_empty,
   push = push,
   pop = pop
}

local Stack = class(nil, members)

return Stack
