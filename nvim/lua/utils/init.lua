local modules = {
  colors = require("utils.colors"),
}

return {
  colors = modules.colors,
  setup = function (opts)
    modules.colors.setup(opts.colors)
  end,
}
