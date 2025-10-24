return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
  },
  {
    'leoluz/nvim-dap-go',
    ft = { 'go', 'gomod' },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    'mfussenegger/nvim-dap-python',
    ft = { 'python' },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require('dap-python').setup(vim.fn.exepath("python3"))
    end,
  },
}
