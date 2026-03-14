return {
  {
    "Olical/conjure",
    cond = false,
    -- cond = vim.g.vscode == nil,
    ft = { "clojure", "lua", "python" },
    lazy = true,
    init = (function ()
      vim.g["conjure#mapping#doc#word"] = false
      vim.g["conjure#log#hud#passive_close_delay"] = 6000
      vim.g["conjure#log#hud#border"] = "rounded"
      vim.g["conjure#log#hud#open_when"] = "log-win-not-visible"
      vim.g["conjure#log#hud#enabled"] = false

      vim.g["conjure#highlight#enabled"] = true
      vim.g["conjure#eval#inline#prefix"] = '↳ '
      -- vim.cmd({ cmd = "highlight", args = { "link", "FloatNormal", "QuickFixLine"}, bang = true })
      -- vim.cmd({ cmd = "highlight", args = { "link", "FloatBorder", "FloatNormal"}, bang = true })
      vim.g["conjure#log#trim#at"] = 10000
      vim.g["conjure#log#trim#to"] = 8000
      return function(_, opts) vim.g["conjure#mapping#doc#word"] = "<localleader>K" end
    end)(),
  },
  {
    "PaterJason/cmp-conjure",
    cond = false,
    -- cond = vim.g.vscode == nil,
    dependencies = { "Olical/conjure" },
  },
}
