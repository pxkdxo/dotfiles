return {
  {
    "iamcco/markdown-preview.nvim",
    cond = vim.g.vscode == nil and vim.fn.executable("yarn") == 1,
    build = "yarn --cwd app install",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown", "Avante" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown", "Avante" }
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
    },
  },
}
