-- setup lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable releasepl
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "rebelot/kanagawa.nvim",
        config = function()
            vim.cmd.colorscheme("kanagawa-dragon")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "go", "gomod", "gosum", "gowork" },

                auto_install = true,

                highlight = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<leader>ss", -- set to `false` to disable one of the mappings
                        node_incremental = "<leader>si",
                        scope_incremental = "<leader>sc",
                        node_decremental = "<leader>sd",
                    },
                },

                textobjects = {
                    select = {
                        enable = true,

                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            -- You can optionally set descriptions to the mappings (used in the desc parameter of
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            -- You can also use captures from other query groups like `locals.scm`
                            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        },
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'V',  -- linewise
                            ['@class.outer'] = '<c-v>', -- blockwise
                        },
                        include_surrounding_whitespace = true,
                    },
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    {
        "neovim/nvim-lspconfig",
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("mason-lspconfig").setup()
            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end,
            })
        end
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end,
    },
    {
        'stevearc/oil.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = {
            {
                '<leader>o',
                function()
                    require('oil').open()
                end,
                desc = '[F]ormat buffer',
            }
        },
        opts = {
            default_file_explorer = true,
            view_options = {
                show_hidden = true,
            },
        },
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")

            -- REQUIRED
            harpoon:setup()
            -- REQUIRED

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        end
    },
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                svelte = { "eslint_d" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            vim.keymap.set("n", "<leader>ll", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },
    {
        "stevearc/conform.nvim",
        config = function()
            local conform = require("conform")

            conform.setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    svelte = { { "prettierd", "prettier" } },
                    javascript = { { "prettierd", "prettier" } },
                    typescript = { { "prettierd", "prettier" } },
                    javascriptreact = { { "prettierd", "prettier" } },
                    typescriptreact = { { "prettierd", "prettier" } },
                    json = { { "prettierd", "prettier" } },
                    graphql = { { "prettierd", "prettier" } },
                    java = { "google-java-format" },
                    markdown = { { "prettierd", "prettier" } },
                    html = { "htmlbeautifier" },
                    bash = { "beautysh" },
                    proto = { "buf" },
                    toml = { "taplo" },
                    css = { { "prettierd", "prettier" } },
                    scss = { { "prettierd", "prettier" } },
                    sh = { { "shellcheck" } },
                    go = {{"gofump"}}
                },
            })

            vim.keymap.set({ "n", "v" }, "<leader>p", function()
                conform.format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                })
            end, { desc = "Format file or range (in visual mode)" })
        end,
    },
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equalent to setup({}) function
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim"
        },
        config = function()
            local cmp = require("cmp")

            local luasnip = require("luasnip")

            local lspkind = require("lspkind")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "luasnip" },
                },
                completion = {
                    completeopt = "menu,menuone,preview,noselect",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p]"] = cmp.mapping.select_prev_item(),
                    ["<C-n]"] = cmp.mapping.select_next_item(),
                    ["<C-u]"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d]"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    pl
                }),

                formatting = {
                    format = lspkind.cmp_format({
                        maxwidth = 50,
                        ellipsis_char = "...",
                    })
                }
            })
        end
    },
    {
        "github/copilot.vim"
    },
    {
        "rmgatti/auto-session",
        config = function()
            require("auto-session").setup({
                auto_restore_enabled = true,
                auto_save_enabled = true,
                auto_session_enable_last_session = true,
                auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
            })
        end
    },
    -- {
    --     "iabdelkareem/csharp.nvim",
    --     dependencies = {
    --         "williamboman/mason.nvim", -- Required, automatically installs omnisharp
    --         "mfussenegger/nvim-dap",
    --         "Tastyep/structlog.nvim",  -- Optional, but highly recommended for debugging
    --     },
    --     config = function()
    --         require("mason").setup() -- Mason setup must run before csharp
    --         require("csharp").setup({
    --             lsp = {
    --                 -- When set to false, csharp.nvim won't launch omnisharp automatically.
    --                 enable = true,
    --                 -- When set, csharp.nvim won't install omnisharp automatically. Instead, the omnisharp instance in the cmd_path will be used.
    --                 cmd_path = nil,
    --                 -- The default timeout when communicating with omnisharp
    --                 default_timeout = 1000,
    --                 -- Settings that'll be passed to the omnisharp server
    --                 enable_editor_config_support = true,
    --                 organize_imports = true,
    --                 load_projects_on_demand = false,
    --                 enable_analyzers_support = true,
    --                 enable_import_completion = true,
    --                 include_prerelease_sdks = true,
    --                 analyze_open_documents_only = false,
    --                 enable_package_auto_restore = true,
    --                 -- Launches omnisharp in debug mode
    --                 debug = false,
    --                 -- The capabilities to pass to the omnisharp server
    --                 capabilities = nil,
    --                 -- on_attach function that'll be called when the LSP is attached to a buffer
    --                 on_attach = nil
    --             },
    --             logging = {
    --                 -- The minimum log level.
    --                 level = "INFO",
    --             },
    --             dap = {
    --                 -- When set, csharp.nvim won't launch install and debugger automatically. Instead, it'll use the debug adapter specified.
    --                 --- @type string?
    --                 adapter_name = nil,
    --             }
    --         })
    --         require("csharp").go_to_definition()
    --         require("csharp").fix_all()
    --         require("csharp").fix_usings()
    --         require("csharp").run_project()
    --         require("csharp").debug_project()
    --     end
    -- },
    -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
    {
        'numToStr/Comment.nvim',
        opts = {
            -- add any options here
        },
        lazy = false,
    },
    {
        "smjonas/inc-rename.nvim",
        config = function()
            require("inc_rename").setup()
            vim.keymap.set("n", "<leader>rn", function()
                return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true })
        end,
    }
})
