local M = {}

M.options = require("config.options")
M.lazy = require("config.lazy")
M.setup = function (opts)
  M.options(opts.options)
  M.lazy.setup(opts.lazy)
end

return M
