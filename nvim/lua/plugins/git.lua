return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration

      -- Only one of these is needed.
      --"nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua",              -- optional
      --"nvim-mini/mini.pick",         -- optional
      --"folke/snacks.nvim",             -- optional
    },
    opts = {
      -- Hides the hints at the top of the status buffer
      disable_hint = false,
      -- Disables changing the buffer highlights based on where the cursor is.
      disable_context_highlighting = false,
      -- Disables signs for sections/items/hunks
      disable_signs = false,
      -- Offer to force push when branches diverge
      prompt_force_push = true,
      -- Changes what mode the Commit Editor starts in. `true` will leave nvim in normal mode, `false` will change nvim to
      -- insert mode, and `"auto"` will change nvim to insert mode IF the commit message is empty, otherwise leaving it in
      -- normal mode.
      disable_insert_on_commit = "auto",
      -- When enabled, will watch the `.git/` directory for changes and refresh the status buffer in response to filesystem
      -- events.
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      -- "ascii"   is the graph the git CLI generates
      -- "unicode" is the graph like https://github.com/rbong/vim-flog
      -- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
      graph_style = "unicode",
      -- Show relative date by default. When set, use `strftime` to display dates
      commit_date_format = nil,
      log_date_format = nil,
      -- Used to generate URL's for branch popup action "pull request".
      git_services = {
        ["github.com"] = "https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1",
        ["bitbucket.org"] = "https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1",
        ["gitlab.com"] = "https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
        ["azure.com"] = "https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}",
      },
      -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
      -- sorter instead. By default, this function returns `nil`.
      -- telescope_sorter = function()
      --   return require("telescope").extensions.fzf.native_fzf_sorter()
      -- end,
      -- Persist the values of switches/options within and across sessions
      remember_settings = true,
      -- Scope persisted settings on a per-project basis
      use_per_project_settings = true,
      -- Table of settings to never persist. Uses format "Filetype--cli-value"
      ignored_settings = {},
      -- Configure highlight group features
      highlight = {
        italic = true,
        bold = true,
        underline = true
      },
      -- Set to false if you want to be responsible for creating _ALL_ keymappings
      use_default_keymaps = true,
      -- Neogit refreshes its internal state after specific events, which can be expensive depending on the repository size.
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
      auto_refresh = true,
      -- Value used for `--sort` option for `git branch` command
      -- By default, branches will be sorted by commit date descending
      -- Flag description: https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
      -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
      sort_branches = "-committerdate",
      -- Default for new branch name prompts
      initial_branch_name = "",
      -- Floating window style 
      floating = {
        relative = "editor",
        width = 0.8,
        height = 0.7,
        style = "minimal",
        border = "rounded",
      },
      -- Disable line numbers
      disable_line_numbers = true,
      -- Disable relative line numbers
      disable_relative_line_numbers = true,
      -- The time after which an output console is shown for slow running commands
      console_timeout = 2000,
      -- Automatically show console if a command takes more than console_timeout milliseconds
      auto_show_console = true,
      -- Automatically close the console if the process exits with a 0 (success) status
      auto_close_console = true,
      --
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({']c', bang = true})
          else
            gitsigns.nav_hunk('next')
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({'[c', bang = true})
          else
            gitsigns.nav_hunk('prev')
          end
        end)

        -- Actions
        map('n', '<leader>hs', gitsigns.stage_hunk)
        map('n', '<leader>hr', gitsigns.reset_hunk)

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end)

        map('n', '<leader>hS', gitsigns.stage_buffer)
        map('n', '<leader>hR', gitsigns.reset_buffer)
        map('n', '<leader>hp', gitsigns.preview_hunk)
        map('n', '<leader>hi', gitsigns.preview_hunk_inline)

        map('n', '<leader>hb', function()
          gitsigns.blame_line({ full = true })
        end)

        map('n', '<leader>hd', gitsigns.diffthis)

        map('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end)

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
        map('n', '<leader>hq', gitsigns.setqflist)

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
        map('n', '<leader>tw', gitsigns.toggle_word_diff)

        -- Text object
        map({'o', 'x'}, 'ih', gitsigns.select_hunk)
      end
    },
  },
  -- {
  --   'pwntester/octo.nvim',
  --   requires = {
  --     'nvim-lua/plenary.nvim',
  --     'nvim-telescope/telescope.nvim',
  --     -- OR 'ibhagwan/fzf-lua',
  --     -- OR 'folke/snacks.nvim',
  --     'nvim-tree/nvim-web-devicons',
  --   },
  --   config = function ()
  --     require"octo".setup()
  --   end,
  --   opts = {
  --     use_local_fs = false,                    -- use local files on right side of reviews
  --     enable_builtin = false,                  -- shows a list of builtin actions when no action is provided
  --     default_remote = {"upstream", "origin"}, -- order to try remotes
  --     default_merge_method = "commit",         -- default merge method which should be used for both `Octo pr merge` and merging from picker, could be `commit`, `rebase` or `squash`
  --     default_delete_branch = false,           -- whether to delete branch when merging pull request with either `Octo pr merge` or from picker (can be overridden with `delete`/`nodelete` argument to `Octo pr merge`)
  --     ssh_aliases = {},                        -- SSH aliases. e.g. `ssh_aliases = {["github.com-work"] = "github.com"}`. The key part will be interpreted as an anchored Lua pattern.
  --     picker = "telescope",                    -- or "fzf-lua" or "snacks"
  --     picker_config = {
  --       use_emojis = false,                    -- only used by "fzf-lua" picker for now
  --       mappings = {                           -- mappings for the pickers
  --         open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
  --         copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
  --         copy_sha = { lhs = "<C-e>", desc = "copy commit SHA to system clipboard" },
  --         checkout_pr = { lhs = "<C-o>", desc = "checkout pull request" },
  --         merge_pr = { lhs = "<C-r>", desc = "merge pull request" },
  --       },
  --       snacks = {                                -- snacks specific config
  --         actions = {                             -- custom actions for specific snacks pickers (array of tables)
  --           issues = {                            -- actions for the issues picker
  --             -- { name = "my_issue_action", fn = function(picker, item) print("Issue action:", vim.inspect(item)) end, lhs = "<leader>a", desc = "My custom issue action" },
  --           },
  --           pull_requests = {                     -- actions for the pull requests picker
  --             -- { name = "my_pr_action", fn = function(picker, item) print("PR action:", vim.inspect(item)) end, lhs = "<leader>b", desc = "My custom PR action" },
  --           },
  --           notifications = {},                   -- actions for the notifications picker
  --           issue_templates = {},                 -- actions for the issue templates picker
  --           search = {},                          -- actions for the search picker
  --           -- ... add actions for other pickers as needed
  --         },
  --       },
  --     },
  --     comment_icon = "▎",                      -- comment marker
  --     outdated_icon = "󰅒 ",                    -- outdated indicator
  --     resolved_icon = " ",                    -- resolved indicator
  --     reaction_viewer_hint_icon = " ",        -- marker for user reactions
  --     commands = {},                           -- additional subcommands made available to `Octo` command
  --     users = "search",                        -- Users for assignees or reviewers. Values: "search" | "mentionable" | "assignable"
  --     user_icon = " ",                        -- user icon
  --     ghost_icon = "󰊠 ",                       -- ghost icon
  --     timeline_marker = " ",                  -- timeline marker
  --     timeline_indent = 2,                   -- timeline indentation
  --     use_timeline_icons = true,               -- toggle timeline icons
  --     timeline_icons = {                       -- the default icons based on timelineItems
  --       commit = "  ",
  --       label = "  ",
  --       reference = " ",
  --       connected = "  ",
  --       subissue = "  ",
  --       cross_reference = "  ",
  --       parent_issue = "  ",
  --       pinned = "  ",
  --       milestone = "  ",
  --       renamed = "  ",
  --       merged = { "  ", "OctoPurple" },
  --       closed = {
  --         closed = { "  ", "OctoRed" },
  --         completed = { "  ", "OctoPurple" },
  --         not_planned = { "  ", "OctoGrey" },
  --         duplicate = { "  ", "OctoGrey" },
  --       },
  --       reopened = { "  ", "OctoGreen" },
  --       assigned = "  ",
  --       review_requested = "  ",
  --     },
  --     right_bubble_delimiter = "",            -- bubble delimiter
  --     left_bubble_delimiter = "",             -- bubble delimiter
  --     github_hostname = "",                    -- GitHub Enterprise host
  --     snippet_context_lines = 4,               -- number or lines around commented lines
  --     gh_cmd = "gh",                           -- Command to use when calling Github CLI
  --     gh_env = {},                             -- extra environment variables to pass on to GitHub CLI, can be a table or function returning a table
  --     timeout = 5000,                          -- timeout for requests between the remote server
  --     default_to_projects_v2 = false,          -- use projects v2 for the `Octo card ...` command by default. Both legacy and v2 commands are available under `Octo cardlegacy ...` and `Octo cardv2 ...` respectively.
  --     ui = {
  --       use_signcolumn = false,                -- show "modified" marks on the sign column
  --       use_signstatus = true,                 -- show "modified" marks on the status column
  --     },
  --     issues = {
  --       order_by = {                           -- criteria to sort results of `Octo issue list`
  --         field = "CREATED_AT",                -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
  --         direction = "DESC"                   -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
  --       }
  --     },
  --     reviews = {
  --       auto_show_threads = true,              -- automatically show comment threads on cursor move
  --       focus             = "right",           -- focus right buffer on diff open
  --     },
  --     runs = {
  --       icons = {
  --         pending = "🕖",
  --         in_progress = "🔄",
  --         failed = "❌",
  --         succeeded = "",
  --         skipped = "⏩",
  --         cancelled = "✖",
  --       },
  --     },
  --     pull_requests = {
  --       order_by = {                            -- criteria to sort the results of `Octo pr list`
  --         field = "CREATED_AT",                 -- either COMMENTS, CREATED_AT or UPDATED_AT (https://docs.github.com/en/graphql/reference/enums#issueorderfield)
  --         direction = "DESC"                    -- either DESC or ASC (https://docs.github.com/en/graphql/reference/enums#orderdirection)
  --       },
  --       always_select_remote_on_create = false, -- always give prompt to select base remote repo when creating PRs
  --       use_branch_name_as_title = false        -- sets branch name to be the name for the PR
  --     },
  --     notifications = {
  --       current_repo_only = false,             -- show notifications for current repo only
  --     },
  --     file_panel = {
  --       size = 10,                             -- changed files panel rows
  --       use_icons = true                       -- use web-devicons in file panel (if false, nvim-web-devicons does not need to be installed)
  --     },
  --     colors = {                               -- used for highlight groups (see Colors section below)
  --       white = "#ffffff",
  --       grey = "#2A354C",
  --       black = "#000000",
  --       red = "#fdb8c0",
  --       dark_red = "#da3633",
  --       green = "#acf2bd",
  --       dark_green = "#238636",
  --       yellow = "#d3c846",
  --       dark_yellow = "#735c0f",
  --       blue = "#58A6FF",
  --       dark_blue = "#0366d6",
  --       purple = "#6f42c1",
  --     },
  --     mappings_disable_default = false,        -- disable default mappings if true, but will still adapt user mappings
  --     mappings = {
  --       runs = {
  --         expand_step = { lhs = "o", desc = "expand workflow step" },
  --         open_in_browser = { lhs = "<C-b>", desc = "open workflow run in browser" },
  --         refresh = { lhs = "<C-r>", desc = "refresh workflow" },
  --         rerun = { lhs = "<C-o>", desc = "rerun workflow" },
  --         rerun_failed = { lhs = "<C-f>", desc = "rerun failed workflow" },
  --         cancel = { lhs = "<C-x>", desc = "cancel workflow" },
  --         copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
  --       },
  --       issue = {
  --         close_issue = { lhs = "<localleader>ic", desc = "close issue" },
  --         reopen_issue = { lhs = "<localleader>io", desc = "reopen issue" },
  --         list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
  --         reload = { lhs = "<C-r>", desc = "reload issue" },
  --         open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
  --         copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
  --         add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
  --         remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
  --         create_label = { lhs = "<localleader>lc", desc = "create label" },
  --         add_label = { lhs = "<localleader>la", desc = "add label" },
  --         remove_label = { lhs = "<localleader>ld", desc = "remove label" },
  --         goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
  --         add_comment = { lhs = "<localleader>ca", desc = "add comment" },
  --         add_reply = { lhs = "<localleader>cr", desc = "add reply" },
  --         delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
  --         next_comment = { lhs = "]c", desc = "go to next comment" },
  --         prev_comment = { lhs = "[c", desc = "go to previous comment" },
  --         react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
  --         react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
  --         react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
  --         react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
  --         react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
  --         react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
  --         react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
  --         react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
  --       },
  --       pull_request = {
  --         checkout_pr = { lhs = "<localleader>po", desc = "checkout PR" },
  --         merge_pr = { lhs = "<localleader>pm", desc = "merge commit PR" },
  --         squash_and_merge_pr = { lhs = "<localleader>psm", desc = "squash and merge PR" },
  --         rebase_and_merge_pr = { lhs = "<localleader>prm", desc = "rebase and merge PR" },
  --         merge_pr_queue = { lhs = "<localleader>pq", desc = "merge commit PR and add to merge queue (Merge queue must be enabled in the repo)" },
  --         squash_and_merge_queue = { lhs = "<localleader>psq", desc = "squash and add to merge queue (Merge queue must be enabled in the repo)" },
  --         rebase_and_merge_queue = { lhs = "<localleader>prq", desc = "rebase and add to merge queue (Merge queue must be enabled in the repo)" },
  --         list_commits = { lhs = "<localleader>pc", desc = "list PR commits" },
  --         list_changed_files = { lhs = "<localleader>pf", desc = "list PR changed files" },
  --         show_pr_diff = { lhs = "<localleader>pd", desc = "show PR diff" },
  --         add_reviewer = { lhs = "<localleader>va", desc = "add reviewer" },
  --         remove_reviewer = { lhs = "<localleader>vd", desc = "remove reviewer request" },
  --         close_issue = { lhs = "<localleader>ic", desc = "close PR" },
  --         reopen_issue = { lhs = "<localleader>io", desc = "reopen PR" },
  --         list_issues = { lhs = "<localleader>il", desc = "list open issues on same repo" },
  --         reload = { lhs = "<C-r>", desc = "reload PR" },
  --         open_in_browser = { lhs = "<C-b>", desc = "open PR in browser" },
  --         copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
  --         goto_file = { lhs = "gf", desc = "go to file" },
  --         add_assignee = { lhs = "<localleader>aa", desc = "add assignee" },
  --         remove_assignee = { lhs = "<localleader>ad", desc = "remove assignee" },
  --         create_label = { lhs = "<localleader>lc", desc = "create label" },
  --         add_label = { lhs = "<localleader>la", desc = "add label" },
  --         remove_label = { lhs = "<localleader>ld", desc = "remove label" },
  --         goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
  --         add_comment = { lhs = "<localleader>ca", desc = "add comment" },
  --         add_reply = { lhs = "<localleader>cr", desc = "add reply" },
  --         delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
  --         next_comment = { lhs = "]c", desc = "go to next comment" },
  --         prev_comment = { lhs = "[c", desc = "go to previous comment" },
  --         react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
  --         react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
  --         react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
  --         react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
  --         react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
  --         react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
  --         react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
  --         react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
  --         review_start = { lhs = "<localleader>vs", desc = "start a review for the current PR" },
  --         review_resume = { lhs = "<localleader>vr", desc = "resume a pending review for the current PR" },
  --         resolve_thread = { lhs = "<localleader>rt", desc = "resolve PR thread" },
  --         unresolve_thread = { lhs = "<localleader>rT", desc = "unresolve PR thread" },
  --       },
  --       review_thread = {
  --         goto_issue = { lhs = "<localleader>gi", desc = "navigate to a local repo issue" },
  --         add_comment = { lhs = "<localleader>ca", desc = "add comment" },
  --         add_reply = { lhs = "<localleader>cr", desc = "add reply" },
  --         add_suggestion = { lhs = "<localleader>sa", desc = "add suggestion" },
  --         delete_comment = { lhs = "<localleader>cd", desc = "delete comment" },
  --         next_comment = { lhs = "]c", desc = "go to next comment" },
  --         prev_comment = { lhs = "[c", desc = "go to previous comment" },
  --         select_next_entry = { lhs = "]q", desc = "move to next changed file" },
  --         select_prev_entry = { lhs = "[q", desc = "move to previous changed file" },
  --         select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
  --         select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
  --         close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
  --         react_hooray = { lhs = "<localleader>rp", desc = "add/remove 🎉 reaction" },
  --         react_heart = { lhs = "<localleader>rh", desc = "add/remove ❤️ reaction" },
  --         react_eyes = { lhs = "<localleader>re", desc = "add/remove 👀 reaction" },
  --         react_thumbs_up = { lhs = "<localleader>r+", desc = "add/remove 👍 reaction" },
  --         react_thumbs_down = { lhs = "<localleader>r-", desc = "add/remove 👎 reaction" },
  --         react_rocket = { lhs = "<localleader>rr", desc = "add/remove 🚀 reaction" },
  --         react_laugh = { lhs = "<localleader>rl", desc = "add/remove 😄 reaction" },
  --         react_confused = { lhs = "<localleader>rc", desc = "add/remove 😕 reaction" },
  --         resolve_thread = { lhs = "<localleader>rt", desc = "resolve PR thread" },
  --         unresolve_thread = { lhs = "<localleader>rT", desc = "unresolve PR thread" },
  --       },
  --       submit_win = {
  --         approve_review = { lhs = "<C-a>", desc = "approve review", mode = { "n", "i" } },
  --         comment_review = { lhs = "<C-m>", desc = "comment review", mode = { "n", "i" } },
  --         request_changes = { lhs = "<C-r>", desc = "request changes review", mode = { "n", "i" } },
  --         close_review_tab = { lhs = "<C-c>", desc = "close review tab", mode = { "n", "i" } },
  --       },
  --       review_diff = {
  --         submit_review = { lhs = "<localleader>vs", desc = "submit review" },
  --         discard_review = { lhs = "<localleader>vd", desc = "discard review" },
  --         add_review_comment = { lhs = "<localleader>ca", desc = "add a new review comment", mode = { "n", "x" } },
  --         add_review_suggestion = { lhs = "<localleader>sa", desc = "add a new review suggestion", mode = { "n", "x" } },
  --         focus_files = { lhs = "<localleader>e", desc = "move focus to changed file panel" },
  --         toggle_files = { lhs = "<localleader>b", desc = "hide/show changed files panel" },
  --         next_thread = { lhs = "]t", desc = "move to next thread" },
  --         prev_thread = { lhs = "[t", desc = "move to previous thread" },
  --         select_next_entry = { lhs = "]q", desc = "move to next changed file" },
  --         select_prev_entry = { lhs = "[q", desc = "move to previous changed file" },
  --         select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
  --         select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
  --         close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
  --         toggle_viewed = { lhs = "<localleader><space>", desc = "toggle viewer viewed state" },
  --         goto_file = { lhs = "gf", desc = "go to file" },
  --       },
  --       file_panel = {
  --         submit_review = { lhs = "<localleader>vs", desc = "submit review" },
  --         discard_review = { lhs = "<localleader>vd", desc = "discard review" },
  --         next_entry = { lhs = "j", desc = "move to next changed file" },
  --         prev_entry = { lhs = "k", desc = "move to previous changed file" },
  --         select_entry = { lhs = "<cr>", desc = "show selected changed file diffs" },
  --         refresh_files = { lhs = "R", desc = "refresh changed files panel" },
  --         focus_files = { lhs = "<localleader>e", desc = "move focus to changed file panel" },
  --         toggle_files = { lhs = "<localleader>b", desc = "hide/show changed files panel" },
  --         select_next_entry = { lhs = "]q", desc = "move to next changed file" },
  --         select_prev_entry = { lhs = "[q", desc = "move to previous changed file" },
  --         select_first_entry = { lhs = "[Q", desc = "move to first changed file" },
  --         select_last_entry = { lhs = "]Q", desc = "move to last changed file" },
  --         close_review_tab = { lhs = "<C-c>", desc = "close review tab" },
  --         toggle_viewed = { lhs = "<localleader><space>", desc = "toggle viewer viewed state" },
  --       },
  --       notification = {
  --         read = { lhs = "<localleader>nr", desc = "mark notification as read" },
  --         done = { lhs = "<localleader>nd", desc = "mark notification as done" },
  --         unsubscribe = { lhs = "<localleader>nu", desc = "unsubscribe from notifications" },
  --       },
  --     },
  --   },
  -- },
}
