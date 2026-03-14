return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "List references")
          map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
          map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
          map("v", "<leader>la", vim.lsp.buf.code_action, "Code action (selection)")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format buffer")
          map("n", "<leader>li", "<cmd>LspInfo<cr>", "LSP info")
          map("n", "<leader>lR", "<cmd>LspRestart<cr>", "Restart LSP")
          map("n", "[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
          end, "Previous diagnostic")
          map("n", "]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
          end, "Next diagnostic")
          map("n", "<leader>ld", function()
            vim.diagnostic.open_float()
          end, "Line diagnostics")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end, "Toggle inlay hints")
          end

          if client and client:supports_method("textDocument/documentSymbol") then
            local ok, navic = pcall(require, "nvim-navic")
            if ok then
              navic.attach(client, buf)
            end
          end
        end,
      })
    end,
  },
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      lsp = { auto_attach = true },
      highlight = true,
      separator = " > ",
      depth_limit = 5,
      icons = {
        File = " ",
        Module = "",
        Namespace = " ",
        Package = "󰏖 ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = "󰭣",
        Field = "󰭣",
        Constructor = "󰙴",
        Enum = "󰕘 ",
        Interface = "󰕘 ",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = "󰀬 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = "󰠱",
        Struct = "󰌗 ",
        Event = "󰛕",
        Operator = "󰥣 ",
        TypeParameter = " ",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = true,
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { "nvim-dap-ui" },
    },
  },
}
