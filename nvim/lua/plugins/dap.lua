return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / Start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down in stack" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up in stack" },
      { "<leader>de", function() require("dap").set_exception_breakpoints() end, desc = "Exception breakpoints" },
    },
    config = function()
      local dap = require("dap")
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◐", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "CursorLine" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        local ok, dapui = pcall(require, "dapui")
        if ok then dapui.open() end
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        local ok, dapui = pcall(require, "dapui")
        if ok then dapui.close() end
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        local ok, dapui = pcall(require, "dapui")
        if ok then dapui.close() end
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>dK", function() require("dapui").eval() end, desc = "Eval under cursor", mode = { "n", "v" } },
    },
    opts = {
      floating = { border = "rounded" },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.35 },
            { id = "breakpoints", size = 0.15 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 12,
        },
      },
    },
  },
  {
    'leoluz/nvim-dap-go',
    ft = { 'go', 'gomod' },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {},
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
