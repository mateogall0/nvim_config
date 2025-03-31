vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.splitbelow = true
vim.o.splitright = true
-- Keymaps
vim.keymap.set("n", "<leader>e", ":Ex<CR>", { noremap = true }) -- Open file explorer
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = true }) -- Save file

-- Plugin management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- File explorer
  { "nvim-tree/nvim-tree.lua", dependencies = "nvim-tree/nvim-web-devicons" },
  
  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = "nvim-lua/plenary.nvim" },
  
  -- LSP & Autocompletion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp", dependencies = {
    "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"
  }},

  -- Treesitter for better syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Status line
  { "nvim-lualine/lualine.nvim" },

  -- Theme
  { "folke/tokyonight.nvim" }
})

-- Setup plugins
require("nvim-tree").setup()
require("lualine").setup({ options = { theme = "tokyonight" } })
require("telescope").setup()
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "python", "javascript", "bash", "c", "cpp" },
  highlight = { enable = true }
})

-- Completion setup
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true })
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" }
  })
})

