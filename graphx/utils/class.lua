local class_metatable = {
   __call = function (self, ...)
      local obj = setmetatable({__class = self}, {
            __index = function (t, k)
               return t.__class[k]
            end,

            __tostring = function (t)
               if t.__tostring then
                  return t:__tostring()
               else
                  return "class"
               end
            end
      })
      if self.__init then self.__init(obj, ...) end
      return obj
   end,

   __index = function (self, k)
      if self.__superclass then return self.__superclass[k] end
   end
}

local class = function (base, members)
   if base == nil then
      base = {}
   end
   local class = {__superclass = base}
   for k, v in pairs(members) do class[k] = v end
   return setmetatable(class, class_metatable)
end

return class
