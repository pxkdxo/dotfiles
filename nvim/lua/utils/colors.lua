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
---@param ignore (fun(element: any): boolean)?  -- skip elements where this returns true
---@return any?
function Playlist:next(shuffle, ignore)
  if self.ring:is_empty() then
    return nil
  end
  local advanced = self.cursor ~= nil
  if self.cursor == nil then
    self.cursor = self.ring.head
  else
    self.cursor = self.cursor.next
  end
  if shuffle then
    local n = (advanced and self.ring.length > 1) and self.ring.length - 1 or self.ring.length
    local steps = math.random(n) - 1
    for _ = 1, steps do
      self.cursor = self.cursor.next
    end
  end
  local start = self.cursor
  repeat
    if not (ignore and ignore(self.cursor.data)) and self.play(self.cursor.data) then
      return self.cursor.data
    end
    self.cursor = self.cursor.next
  until self.cursor == start
  return nil
end

---@param ignore (fun(element: any): boolean)?  -- skip elements where this returns true
---@return any?
function Playlist:prev(ignore)
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
    if not (ignore and ignore(self.cursor.data)) and self.play(self.cursor.data) then
      return self.cursor.data
    end
    self.cursor = self.cursor.prev
  until self.cursor == start
  return nil
end

-- Colorscheme entries are either a name (string) or a table
-- { "name", light = <bool>?, dark = <bool>? }. name_of pulls the name; suits
-- says whether an entry fits a given &background ("light"/"dark") — an untagged
-- entry (a bare string, or a table with neither key set) suits both.
---@param element any
---@return string
local function name_of(element)
  if type(element) == "table" then
    return element[1]
  end
  return element
end

---@param element any
---@param background string  -- "light" or "dark"
---@return boolean
local function suits(element, background)
  if type(element) ~= "table" then
    return true
  end
  if element.light == nil and element.dark == nil then
    return true
  end
  return element[background] == true
end

function M.setup(opts)
  opts = opts or {}
  local colorschemes = opts.colorschemes or vim.g.colorschemes or {}
  local cache_dir = vim.env.XDG_CACHE_HOME or vim.env.HOME .. "/.cache"
  local cache = cache_dir .. "/nvim-colorscheme.txt"

  M.playlist = Playlist:new(colorschemes, function(element)
    return pcall(vim.cmd.colorscheme, name_of(element))
  end)

  -- The cache remembers the last colorscheme per &background, one
  -- "<variant> <name>" line each, so a light/dark flip restores the theme you
  -- last used in that variant instead of a random one.
  ---@return table<string, string>
  local function read_cache()
    local remembered = {}
    local file = io.open(cache, "r")
    if file then
      for line in file:lines() do
        local variant, name = line:match("^(%S+)%s+(.+)$")
        if variant == "light" or variant == "dark" then
          remembered[variant] = name
        end
      end
      file:close()
    end
    return remembered
  end

  ---@param remembered table<string, string>
  local function write_cache(remembered)
    local file = io.open(cache, "w")
    if file then
      for _, variant in ipairs({ "light", "dark" }) do
        if remembered[variant] then
          file:write(variant .. " " .. remembered[variant] .. "\n")
        end
      end
      file:close()
    end
  end

  -- An ignore predicate that skips entries not suiting the current &background,
  -- so rotation stays within the active light/dark set.
  local function off_background()
    local background = vim.o.background
    return function(element)
      return not suits(element, background)
    end
  end

  -- Remember the active colorscheme per &background across launches: rewrite the
  -- matching variant entry on every change (manual via the keymaps below, or any
  -- :colorscheme).
  vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "Cache the active colorscheme per background",
    callback = function(ev)
      local remembered = read_cache()
      remembered[vim.o.background] = ev.match
      write_cache(remembered)
    end,
  })

  function M.add(name)
    M.playlist:add(name)
    print("Added " .. name)
  end

  function M.skip()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    else
      M.playlist:skip()
      print("Skipped colorscheme: " .. name_of(M.playlist.cursor.data))
    end
  end

  function M.next()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    elseif M.playlist:next(false, off_background()) then
      print("Set colorscheme: " .. vim.g.colors_name)
    else
      print("No colorscheme in `vim.g.colorschemes` suits background=" .. vim.o.background)
    end
  end

  function M.prev()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    elseif M.playlist:prev(off_background()) then
      print(vim.g.colors_name)
    else
      print("No colorscheme in `vim.g.colorschemes` suits background=" .. vim.o.background)
    end
  end

  function M.shuffle()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
    elseif M.playlist:next(true, off_background()) then
      print(vim.g.colors_name)
    else
      print("No colorscheme in `vim.g.colorschemes` suits background=" .. vim.o.background)
    end
  end

  -- On launch: restore the cached colorscheme for the current background if it
  -- still loads, else shuffle (filtered to that background).
  function M.restore()
    if M.playlist.ring:is_empty() then
      print("Add colorscheme names to `vim.g.colorschemes`")
      return nil
    end
    local cached = read_cache()[vim.o.background]
    if cached and pcall(vim.cmd.colorscheme, cached) then
      return cached
    end
    return M.shuffle()
  end

  -- Find the annotated entry for the active colorscheme (matched by name).
  local function active_entry()
    for _, element in ipairs(colorschemes) do
      if name_of(element) == vim.g.colors_name then
        return element
      end
    end
    return nil
  end

  -- Follow the terminal's light/dark live. set-term-theme publishes the active
  -- variant to this file (the same one the shell's precmd watcher reads); on
  -- focus, match &background and keep the colorscheme suitable.
  local term_theme_file = cache_dir .. "/term-theme.txt"
  function M.sync()
    local file = io.open(term_theme_file, "r")
    local want = file and file:read("*l") or nil
    if file then
      file:close()
    end
    if (want ~= "light" and want ~= "dark") or want == vim.o.background then
      return
    end
    vim.o.background = want
    -- Keep the current scheme if it suits the new variant (re-applying refreshes
    -- adaptive schemes); otherwise restore that variant's cached theme, and only
    -- shuffle as a last resort.
    local current = active_entry()
    if current and suits(current, want) then
      pcall(vim.cmd.colorscheme, name_of(current))
      return
    end
    local cached = read_cache()[want]
    if cached and pcall(vim.cmd.colorscheme, cached) then
      return
    end
    M.shuffle()
  end

  vim.api.nvim_create_autocmd("FocusGained", {
    desc = "Follow the terminal's light/dark theme",
    callback = function()
      M.sync()
    end,
  })

  return M
end

return M
