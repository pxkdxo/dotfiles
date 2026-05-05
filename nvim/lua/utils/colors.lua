-- colors.lua: return an interface to cycle through vim.g.colorschemes
local M = {}

---@class DoubleNode
---@field data any
---@field prev DoubleNode?
---@field next DoubleNode?
local DoubleNode = {
  data = nil,
  prev = nil,
  next = nil,
}
DoubleNode.__index = DoubleNode

---@class Deque
---@field head DoubleNode?
---@field rear DoubleNode?
---@field length integer
local Deque = {
  head = nil,
  rear = nil,
  length = 0,
}
Deque.__index = Deque

---@class Playlist
---@field ring Deque?
---@field cursor DoubleNode?
---@field play fun(element: any): boolean
local Playlist = {
  ring = nil,
  cursor = nil,
  play = function(_)
    return true
  end,
}
Playlist.__index = Playlist

---@param data any
---@return DoubleNode
function DoubleNode:new(data)
  local new = setmetatable({}, self)
  new.data = data
  return new
end

---@param node DoubleNode?
---@return DoubleNode
function DoubleNode:insert_next(node)
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

---@param node DoubleNode?
---@return DoubleNode
function DoubleNode:insert_prev(node)
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

---@return DoubleNode?, DoubleNode?
function DoubleNode:remove()
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

---@param values any[]?
---@return Deque
function Deque:new(values)
  local new = setmetatable({}, self)
  if values ~= nil then
    new = new:init(values)
  end
  return new
end

---@param values any[]
---@return Deque
function Deque:init(values)
  self:clear()
  for _, element in ipairs(values) do
    self:push_rear(element)
  end
  return self
end

---@return Deque
function Deque:clear()
  self.head = nil
  self.rear = nil
  self.length = 0
  return self
end

---@param value any
---@return Deque
function Deque:push_front(value)
  local node = DoubleNode:new(value)
  if self.head == nil then
    self.head = node:insert_next(node)
    self.rear = self.head
  else
    self.head = self.head:insert_prev(node).prev
  end
  self.length = self.length + 1
  return self
end

---@param value any
---@return Deque
function Deque:push_rear(value)
  local node = DoubleNode:new(value)
  if self.rear == nil then
    self.rear = node:insert_prev(node)
    self.head = self.rear
  else
    self.rear = self.rear:insert_next(node).next
  end
  self.length = self.length + 1
  return self
end

---@return any?
function Deque:peek_front()
  local data = nil
  if self.head ~= nil then
    data = self.head.data
  end
  return data
end

---@return any?
function Deque:peek_rear()
  local data = nil
  if self.rear ~= nil then
    data = self.rear.data
  end
  return data
end

---@return any?
function Deque:pop_front()
  local data = nil
  if self.head ~= nil then
    data = self.head.data
    self.head, self.rear = self.head:remove()
    self.length = self.length - 1
  end
  return data
end

---@return any?
function Deque:pop_rear()
  local data = nil
  if self.rear ~= nil then
    data = self.rear.data
    self.head, self.rear = self.rear:remove()
    self.length = self.length - 1
  end
  return data
end

---@param n integer
---@return Deque
function Deque:shift(n)
  if self:is_empty() then
    return self
  end
  local traverse
  if n > 0 then
    traverse = function(node)
      return node.next
    end
  else
    n = n * -1
    traverse = function(node)
      return node.prev
    end
  end
  n = n % self.length
  while n > 0 do
    self.head, self.rear = traverse(self.head), traverse(self.rear)
    n = n - 1
  end
  return self
end

---@return boolean
function Deque:is_empty()
  return self.head == nil
end

---@param list any[]?
---@param play (fun(element: any): boolean)?
---@return Playlist
function Playlist:new(list, play)
  local new = setmetatable({}, self)
  new.ring = Deque:new(list)
  new.cursor = nil
  new.play = play or function(element)
    print(element)
    return true
  end
  return new
end

---@param element any
---@return Playlist
function Playlist:add(element)
  self.ring:push_rear(element)
  return self
end

---@param n integer?
---@return any?
function Playlist:skip(n)
  if self.ring:is_empty() then
    return nil
  end
  n = n or 1
  if self.cursor == nil then
    self.cursor = self.ring.head
    n = n - 1
  end
  for _ = 1, n do
    self.cursor = self.cursor.next
  end
  return self.cursor.data
end

---@param shuffle boolean?
---@return any?
function Playlist:next(shuffle)
  if self.ring:is_empty() then
    return nil
  end
  if self.cursor == nil then
    self.cursor = self.ring.head
  else
    self.cursor = self.cursor.next
  end
  if shuffle then
    local steps = math.random(self.ring.length) - 1
    for _ = 1, steps do
      self.cursor = self.cursor.next
    end
  end
  local start = self.cursor
  repeat
    if self.play(self.cursor.data) then
      return self.cursor.data
    end
    self.cursor = self.cursor.next
  until self.cursor == start
  return nil
end

---@return any?
function Playlist:prev()
  if self.ring:is_empty() then
    return nil
  end
  if self.cursor == nil then
    self.cursor = self.ring.rear
  else
    self.cursor = self.cursor.prev
  end
  local start = self.cursor
  repeat
    if self.play(self.cursor.data) then
      return self.cursor.data
    end
    self.cursor = self.cursor.prev
  until self.cursor == start
  return nil
end

function M.setup(opts)
  opts = opts or {}
  local colorschemes = opts.colorschemes or vim.g.colorschemes or {}

  M.playlist = Playlist:new(colorschemes, function(x)
    return pcall(vim.cmd.colorscheme, x)
  end)

  function M.add(name)
    M.playlist:add(name)
    print("Added " .. name)
  end

  function M.skip()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    else
      M.playlist:skip()
      print("Skipped colorscheme: " .. M.playlist.cursor.data)
    end
  end

  function M.next()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to  `vim.g.colorschemes`")
    elseif M.playlist:next() then
      print("Set colorscheme: " .. vim.g.colors_name)
    else
      print("None of the colorschemes in `vim.g.colorschemes` were found on the system")
    end
  end

  function M.prev()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    elseif M.playlist:prev() then
      print(vim.g.colors_name)
    else
      print("None of the colorschemes in `vim.g.colorschemes` were found on the system")
    end
  end

  function M.shuffle()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    elseif M.playlist:next(true) then
      print(vim.g.colors_name)
    else
      print("None of the colorschemes in `vim.g.colorschemes` were found on the system")
    end
  end

  return M
end

return M
