return {
  { "EdenEast/nightfox.nvim" },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end
  },
}

