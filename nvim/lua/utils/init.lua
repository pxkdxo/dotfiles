local M = {}

M.colors = require("utils.colors")
M.setup = function (opts)
  M.colors.setup(opts.colors)
end

return M
