-- setup lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
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
               ensure_installed = {"c", "lua", "vim", "vimdoc", "query" },

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
                           ['@function.outer'] = 'V', -- linewise
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
       confing = function()
           local lspconfig = require("lspconfig")
           lspconfig.clangd.setup({})
           lspconfig.lua_language_server.setup({})
       end,
   },
   {
       "williamboman/mason.nvim",
       config = function()
           require("mason").setup()
       end
   }
})
