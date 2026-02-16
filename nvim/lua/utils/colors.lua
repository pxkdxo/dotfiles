-- colors.lua: return an interface to cycle through vim.g.colorschemes
local M = {}

local Deque = require('utils.deque').Deque

local Playlist = {
  all = nil,
  queue = nil,
  play_function = function (_) return true end,
}

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

M.setup = function (opts)
  opts = opts or {}
  vim.g.colorschemes = opts.colorschemes or vim.g.colorschemes or {}

  M.playlist = Playlist:new(
    vim.g.colorschemes, function (name)
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
    if #M.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:next(shuffle) or M.playlist:restart():next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function M.next(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if #M.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:next(shuffle) or M.playlist:restart():next(shuffle) then
      print(vim.g.colors_name)
    else
      print("None of vim.g.colorschemes found on the system")
    end
  end

  function M.prev(options)
    options = options or {}
    local shuffle = options.shuffle or false
    if #M.playlist.all == 0 then
      print("Add colorschemes to vim.g.colorschemes")
    elseif M.playlist:next(shuffle) or M.playlist:restart():next(shuffle) then
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
