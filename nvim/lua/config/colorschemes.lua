-- colorschemes.lua: return an interface to cycle through vim.g.colorschemes

Colorschemes = Colorschemes or {
  setup = function (_) end
}
local Playlist = {
  all = nil,
  queue = nil,
  play_function = function (_) return true end,
}
local Node = {
  data = nil,
  prev = nil,
  next = nil,
}
local Deque = {
  head = nil,
  tail = nil,
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

function Deque:new(tab)
  local new = { head = nil, tail = nil }
  setmetatable(new, self)
  self.__index = self
  if tab ~= nil then
    new = new:copy(tab)
  end
  return new
end

function Deque:copy(tab)
  self:clear()
  if tab ~= nil then
    for _, value in ipairs(tab) do
      self:push_rear(value)
    end
  end
  return self
end

function Deque:clear()
  self.head = nil
  self.tail = nil
  return self
end

function Deque:push_front(value)
  local node = Node:new(value)
  if self.head == nil then
    self.head = node:insert_next(node)
    self.tail = self.head
  else
    self.head = self.head:insert_prev(node).prev
  end
  return self
end

function Deque:push_rear(value)
  local node = Node:new(value)
  if self.tail == nil then
    self.tail = node:insert_prev(node)
    self.head = self.tail
  else
    self.tail = self.tail:insert_next(node).next
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
  if self.tail ~= nil then
    data = self.tail.data
  end
  return data
end

function Deque:pop_front()
  local data = nil
  if self.head ~= nil then
    data = self.head.data
    self.head, self.tail = self.head:remove()
  end
  return data
end

function Deque:pop_rear()
  local data = nil
  if self.tail ~= nil then
    data = self.tail.data
    self.head, self.tail = self.tail:remove()
  end
  return data
end

function Deque:shift(n)
  local shift_one = nil
  if n > 0 then
    shift_one = function (deque) return deque.head.next, deque.tail.next end
  else
    n = n * -1
    shift_one = function (deque) return deque.head.prev, deque.tail.prev end
  end
  while n > 0 do
    self.head, self.tail = shift_one(self)
    n = n - 1
  end
  return self
end

function Deque:isempty()
  return self.head == nil
end

function Playlist:new(items, play)
  local all = items or {}
  local play_function = play or function (element)
    vim.print(element)
    return true
  end
  local new = { all = all, queue = Deque:new(all), play_function = play_function }
  setmetatable(new, self)
  self.__index = self
  return new
end

function Playlist:restart()
  self.queue = Deque:new(self.all)
  return self
end

function Playlist:add(element)
  table.insert(self.all, element)
  self.queue:push_rear(element)
  return self
end

function Playlist:next(shuffle)
  while not self.queue:isempty() do
    if shuffle then
      self.queue:shift(math.random(#self.all))
    end
    local name = self.queue:pop_front()
    if self.play_function(name) then
      return name
    end
  end
  return nil
end

function Colorschemes.setup(opts)
  opts = opts or {}
  vim.g.colorschemes = opts.colorschemes or vim.g.colorschemes or {}

  Colorschemes.playlist = Playlist:new(
    vim.g.colorschemes, function (name)
      return pcall(vim.cmd.colorscheme, name)
    end
  )

  function Colorschemes.add(name)
    if Colorschemes.playlist:add(name) then
      print("Added " .. name)
    else
      print("Failed to add " .. name)
    end
  end

  function Colorschemes.skip(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if #Colorschemes.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif Colorschemes.playlist:next(shuffle) or Colorschemes.playlist:restart():next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function Colorschemes.next(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if #Colorschemes.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif Colorschemes.playlist:next(shuffle) or Colorschemes.playlist:restart():next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function Colorschemes.prev(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if #Colorschemes.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif Colorschemes.playlist:next(shuffle) or Colorschemes.playlist:restart():next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function Colorschemes.shuffle()
    Colorschemes.next({ shuffle = true })
  end

  return Colorschemes
end

return Colorschemes
