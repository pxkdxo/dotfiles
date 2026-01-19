local modules = {
  colors = require("config.colors"),
}

return {
  colors = modules.colors,
  setup = function (opts)
    modules.colors.setup(opts.colors)
  end,
}
