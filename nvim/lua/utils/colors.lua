-- colors.lua: return an interface to cycle through vim.g.colorschemes
local M = {}

local Playlist = {
  queue = nil,
  history = nil,
  current = nil,
  play = function (_) return true end,
}

local Deque = {
  head = nil,
  rear = nil,
  length = 0,
}

local DoubleListNode = {
  data = nil,
  prev = nil,
  next = nil,
}

function DoubleListNode:new(data)
  local new = { data = data }
  setmetatable(new, self)
  self.__index = self
  return new
end

function DoubleListNode:insert_next(node)
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

function DoubleListNode:insert_prev(node)
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

function DoubleListNode:remove()
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
  local new = {
    head = nil,
    rear = nil,
    length = 0,
  }
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
  self.length = 0
  return self
end

function Deque:push_front(value)
  local node = DoubleListNode:new(value)
  if self.head == nil then
    self.head = node:insert_next(node)
    self.rear = self.head
  else
    self.head = self.head:insert_prev(node).prev
  end
  self.length = self.length + 1
  return self
end

function Deque:push_rear(value)
  local node = DoubleListNode:new(value)
  if self.rear == nil then
    self.rear = node:insert_prev(node)
    self.head = self.rear
  else
    self.rear = self.rear:insert_next(node).next
  end
  self.length = self.length + 1
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
    self.length = self.length - 1
  end
  return data
end

function Deque:pop_rear()
  local data = nil
  if self.rear ~= nil then
    data = self.rear.data
    self.head, self.rear = self.rear:remove()
    self.length = self.length - 1
  end
  return data
end

function Deque:shift(n)
  local traverse
  if n > 0 then
    traverse = function (node) return node.next end
  else
    n = n * -1
    traverse = function (node) return node.prev end
  end
  n = n % self.length
  while n > 0 do
    self.head, self.rear = traverse(self.head), traverse(self.rear)
    n = n - 1
  end
  return self
end

function Deque:is_empty()
  return self.head == nil
end

function Playlist:new(list, play)
  local play = play or function (element)
    print(element)
    return true
  end
  local new = {
    queue = Deque:new(list),
    history = Deque:new(nil),
    current = nil,
    play = play,
  }
  setmetatable(new, self)
  self.__index = self
  return new
end

function Playlist:restart()
  while not self.history:is_empty() do
    self.queue:push_front(self.history:pop_front())
  end
  self.current = nil
  return self
end

function Playlist:add(element)
  self.queue:push_rear(element)
  return self
end

function Playlist:skip(shuffle)
  if not self.queue:is_empty() then
    if shuffle then
      self.queue:shift(math.random(self.queue.length))
    end
    return self.queue:pop_front()
  end
  return nil
end

function Playlist:next(shuffle)
  while not self.queue:is_empty() do
    if shuffle then
      self.queue:shift(math.random(self.queue.length))
    end
    self.current = self.queue:pop_front()
    self.history:push_front(self.current)
    if self.play(self.current) then
      return self.current
    end
  end
  return nil
end

function Playlist:prev()
  self.current = self.history:pop_front()
  while not self.history:is_empty() do
    self.queue:push_front(self.current)
    self.current = self.history:pop_front()
    if self.play(self.current) then
      self.history:push_front(self.current)
      return self.current
    end
  end
  if self.current ~= nil then
    self.history:push_front(self.current)
  end
  return nil
end

M.setup = function (opts)
  opts = opts or {}
  vim.g.colorschemes = opts.colorschemes or vim.g.colorschemes or {}

  M.playlist = Playlist:new(
    vim.g.colorschemes,
    function (name)
      return pcall(vim.cmd.colorscheme, name)
    end
  )

  function M.add(name)
    if M.playlist:add(name) then
      print("Added " .. name)
    else
      print("Failed to add " .. name)
    end
  end

  function M.skip(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if M.playlist.queue:is_empty() then
      M.playlist:restart()
    end
    if M.playlist.queue:is_empty() then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:skip(shuffle) then
      print(vim.g.colors_name)
    end
  end

  function M.next(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if M.playlist.queue:is_empty() then
      M.playlist:restart()
    end
    if M.playlist.queue:is_empty() then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function M.prev(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if M.playlist.queue:is_empty() then
      M.playlist:restart()
    end
    if M.playlist.queue:is_empty() then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:prev(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function M.shuffle()
    M.next({ shuffle = true })
  end

  return M
end

return M
