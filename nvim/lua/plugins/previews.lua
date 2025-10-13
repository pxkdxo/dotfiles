return {
  -- install without yarn or npm
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    cond = not vim.g.vscode,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
}
