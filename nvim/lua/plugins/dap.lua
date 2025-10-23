return {
  {
    "mfussenegger/nvim-dap",
  },
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
      local venv = os.getenv('VIRTUALENV')
      require('dap-python').setup(venv ~= nil and venv .. '/bin/python' or 'python3')
    end,
  },
}
