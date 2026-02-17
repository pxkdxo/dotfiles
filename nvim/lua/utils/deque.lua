-- colors.lua: return an interface to cycle through vim.g.colorschemes
local M = {}

local Node = {
  data = nil,
  prev = nil,
  next = nil,
}
local Deque = {
  head = nil,
  rear = nil,
}

function Node:new(data)
  local new = { data = data }
  setmetatable(new, self)
  self.__index = self
  return new
end

function Node:insert_next(node)
  if node ~= nil then
    node.prev = self
    if self.next ~= nil then
      node.next = self.next
      node.next.prev = node
    else
      node.next = nil
    end
  end
  self.next = node
  return self
end

function Node:insert_prev(node)
  if node ~= nil then
    node.next = self
    if self.prev ~= nil then
      node.prev = self.prev
      node.prev.next = node
    else
      node.prev = nil
    end
  end
  self.prev = node
  return self
end

function Node:remove()
  local next = nil
  local prev = nil
  if self.next ~= self then
    next = self.next
  end
  self.next = nil
  if self.prev ~= self then
    prev = self.prev
  end
  self.prev = nil
  if next ~= nil then
    next.prev = prev
  end
  if prev ~= nil then
    prev.next = next
  end
  return next, prev
end

function Deque:new(values)
  local new = { head = nil, rear = nil }
  setmetatable(new, self)
  self.__index = self
  if values ~= nil then
    new = new:init(values)
  end
  return new
end

function Deque:init(values)
  self:clear()
  for _, element in ipairs(values) do
    self:push_rear(element)
  end
  return self
end

function Deque:clear()
  self.head = nil
  self.rear = nil
  return self
end

function Deque:push_front(value)
  local node = Node:new(value)
  if self.head == nil then
    self.head = node:insert_next(node)
    self.rear = self.head
  else
    self.head = self.head:insert_prev(node).prev
  end
  return self
end

function Deque:push_rear(value)
  local node = Node:new(value)
  if self.rear == nil then
    self.rear = node:insert_prev(node)
    self.head = self.rear
  else
    self.rear = self.rear:insert_next(node).next
  end
  return self
end

function Deque:peek_front()
  local data = nil
  if self.head ~= nil then
    data = self.head.data
  end
  return data
end

function Deque:peek_rear()
  local data = nil
  if self.rear ~= nil then
    data = self.rear.data
  end
  return data
end

function Deque:pop_front()
  local data = nil
  if self.head ~= nil then
    data = self.head.data
    self.head, self.rear = self.head:remove()
  end
  return data
end

function Deque:pop_rear()
  local data = nil
  if self.rear ~= nil then
    data = self.rear.data
    self.head, self.rear = self.rear:remove()
  end
  return data
end

function Deque:shift(n)
  local shift_one = nil
  if n > 0 then
    shift_one = function (deque) return deque.head.next, deque.rear.next end
  else
    n = n * -1
    shift_one = function (deque) return deque.head.prev, deque.rear.prev end
  end
  while n > 0 do
    self.head, self.rear = shift_one(self)
    n = n - 1
  end
  return self
end

function Deque:isempty()
  return self.head == nil
end

M.setup = function (_)
  M.Deque = Deque
  M.Node = Node
  return M
end

M.Deque = Deque
M.Node = Node

return M
