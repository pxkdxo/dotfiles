return {
  {
    'ph1losof/ecolog.nvim',
    branch = "v1",
    keys = {
      { '<leader>e', '', desc = '+ecolog', mode = { 'n', 'v' } },
      { '<leader>el', '<Cmd>EcologShelterLinePeek<cr>', desc = 'Peek line' },
      { '<leader>ey', '<Cmd>EcologCopy<cr>', desc = 'Copy value under cursor' },
      { '<leader>ei', '<Cmd>EcologInterpolationToggle<cr>', desc = 'Toggle interpolation' },
      { '<leader>eh', '<Cmd>EcologShellToggle<cr>', desc = 'Toggle shell variables' },
      { '<leader>ge', '<cmd>EcologGoto<cr>', desc = 'Go to env file' },
      { '<leader>ec', '<cmd>EcologSnacks<cr>', desc = 'Open a picker' },
      { '<leader>eS', '<cmd>EcologSelect<cr>', desc = 'Switch env file' },
      { '<leader>es', '<cmd>EcologShelterToggle<cr>', desc = 'Shelter toggle' },
    },
    opts = {
      preferred_environment = 'local',
      types = true,
      monorepo = {
        enabled = true,
        auto_switch = true,
        notify_on_switch = false,
      },
      providers = {
        {
          pattern = '{{[%w_]+}}?$',
          filetype = 'http',
          extract_var = function(line, col)
            local utils = require 'ecolog.utils'
            return utils.extract_env_var(line, col, '{{([%w_]+)}}?$')
          end,
          get_completion_trigger = function()
            return '{{'
          end,
        },
      },
      interpolation = {
        enabled = true,
        features = {
          max_iterations = 1,
          commands = false,
        },
      },
      sort_var_fn = function(a, b)
        if a.source == 'shell' and b.source ~= 'shell' then
          return false
        end
        if a.source ~= 'shell' and b.source == 'shell' then
          return true
        end

        return a.name < b.name
      end,
      integrations = {
        lspsaga = false,
        lsp = false,
        fzf = {
          shelter = {
            mask_on_copy = false, -- Whether to mask values when copying
          },
          mappings = {
            copy_value = "ctrl-y",  -- Copy variable value to clipboard
            copy_name = "ctrl-n",   -- Copy variable name to clipboard
            append_value = "ctrl-a", -- Append value at cursor position
            append_name = "enter",   -- Append name at cursor position
            edit_var = "ctrl-e",     -- Edit environment variable
          },
        },
        snacks = {
          shelter = {
            mask_on_copy = false, -- Whether to mask values when copying
          },
          keys = {
            copy_value = "<C-y>",  -- Copy variable value to clipboard
            copy_name = "<C-S-y>", -- Copy variable name to clipboard (avoid <C-u> which snacks input uses for kill-to-line-start)
            append_value = "<C-a>", -- Append value at cursor position
            append_name = "<CR>",   -- Append name at cursor position
            edit_var = "<C-e>",     -- Edit environment variable
          },
          layout = {  -- Any Snacks layout configuration
            preset = "dropdown",
            preview = false,
          },
        },
        statusline = {
          hidden_mode = true,
          icons = { enabled = true, env = 'E', shelter = 'S' },
          highlights = {
            enabled = true,
            env_file = 'Directory',
            vars_count = 'Number',
            icons = "Special",
          },
        },
      },
      shelter = {
        configuration = {
          patterns = {
            ['DATABASE_URL'] = 'full',
          },
          sources = {
            ['.env.example'] = 'none',
          },
          partial_mode = {
            min_mask = 5,
            show_start = 1,
            show_end = 1,
          },
          mask_char = '*',
        },
        modules = {
          files = true,
          peek = false,
          snacks_previewer = true,
          snacks = false,
          cmp = true,
        },
      },
      path = vim.fn.getcwd(),
    },
  }
}
