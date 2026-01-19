local modules = {
  options = require("config.options"),
  lazy = require("config.lazy")
}

return {
  options = modules.options,
  lazy = modules.lazy,
  setup = function (opts)
    modules.options.setup(opts.options)
    modules.lazy.setup(opts.lazy)
  end,
}
