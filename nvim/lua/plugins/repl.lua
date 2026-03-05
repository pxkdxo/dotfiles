return {
  {
    "Olical/conjure",
    -- cond = false,
    cond = vim.g.vscode == nil,
    ft = {
      "clojure",
      "elixir",
      "fennel",
      "janet",
      "hy",
      "julia",
      "racket",
      "scheme",
      "lua",
      "lisp",
      -- "python",
      -- "ruby",
      -- "rust",
      -- "sql",
    },
    lazy = true,
    init = function (_, opts)
      vim.g["conjure#log#hud#passive_close_delay"] = 5000
      vim.g["conjure#log#hud#border"] = "rounded"
      vim.g["conjure#log#hud#open_when"] = "log-win-not-visible"

      vim.g["conjure#log#hud#enabled"] = false
      vim.g["conjure#log#trim#at"] = 10000
      vim.g["conjure#log#trim#to"] = 8000

      vim.cmd({ cmd = "highlight", args = { "link", "FloatNormal", "QuickFixLine"}, bang = true })
      vim.cmd({ cmd = "highlight", args = { "link", "FloatBorder", "FloatNormal"}, bang = true })
    end
  },
  {
    "PaterJason/cmp-conjure",
    -- cond = false,
    cond = vim.g.vscode == nil,
    dependencies = { "Olical/conjure" },
  },
}
