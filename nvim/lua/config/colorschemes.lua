-- colors.lua: return a function to cycle through vim.g.colorschemes

local colors_index = 1
local colors_choices = {}
local colors_cycle_ops = {}

local colors_loop_base = function (cycle_next)
  return function (index, choices)
    local name = nil
    while #colors_choices > 0 do
      index, name = cycle_next(index, choices)
      if pcall(vim.cmd.colorscheme, name) then
        return index
      end
    end
    return nil
  end
end

colors_cycle_ops.default = colors_loop_base(function (index, choices)
  if #choices == 0 then return nil end
  index = index < #choices and index or 1
  local name = choices[index]
  table.remove(choices, index)
  return index, name
end)

colors_cycle_ops.shuffle = colors_loop_base(function (index, choices)
  if #choices == 0 then return nil end
  index = math.random(#choices)
  local name = choices[index]
  table.remove(choices, index)
  return index, name
end)

-- Refresh choices list while tracking index
local function colors_reset()
  colors_index = 1
  while #colors_choices > 0 do
    table.remove(colors_choices)
  end
  for index, name in ipairs(vim.g.colorschemes) do
    if name == vim.g.colors_name then
      colors_index = (index % #vim.g.colorschemes) + 1
    else
      table.insert(colors_choices, name)
    end
  end
end

-- Cycle through entries in vim.g.colorschemes
---@param cycle string Cycle operation. Choices:
---   - `'linear'`
---   - `'shuffle'`
local function colors_cycle(cycle)
  if #colors_choices == 0 then
    colors_reset()
  elseif colors_index > #colors_choices then
    colors_index = #colors_choices
  end
  local cycle_op = colors_cycle_ops[cycle]
  if cycle_op == nil then
    return nil
  end
  colors_index = cycle_op(colors_index, colors_choices)
  return colors_index
end

-- Cycle through entries in vim.g.colorschemes
---@param options table|nil Cycle options. Fields:
---   - `'cycle'` - Cycle operation. Choices:
---     - `'default'`
---     - `'shuffle'`
return function(options)
  options = options or {}
  local cycle_name = options.cycle or "default"
  if colors_cycle_ops[cycle_name] == nil then
    print("error: 'rotation' must be 'linear' or 'shuffle'")
  elseif vim.g.colorschemes == nil or #vim.g.colorschemes == 0 then
    print("Add colorschemes to vim.g.colorschemes")
  elseif colors_cycle(cycle_name) then
    print(vim.g.colors_name)
  else
    print("No colorschemes in vim.g.colorschemes found on the system")
  end
end
