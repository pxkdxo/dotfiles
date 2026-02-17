return {
  {
    "Olical/conjure",
    cond = false,
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
    init = function()
      -- Set configuration options here
      -- Uncomment this to get verbose logging to help diagnose internal Conjure issues
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true
    end,
    -- Optional cmp-conjure integration
  },
}
