  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.termguicolors = false
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

  })

  -- Setup plugins
  require("nvim-web-devicons").setup()
  require("nvim-tree").setup({
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Close NvimTree after opening file
      vim.keymap.set("n", "<CR>", function()
        api.node.open.edit()
        api.tree.close()
      end, opts("Open and Close Tree"))
    end,
  })
  require("telescope").setup()
  require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "javascript", "bash",
      "c", "cpp", "gdscript", "godot_resource", "gdshader","rust", "java",
      "c_sharp", "go", "gdscript", "html", "css", "json", "yaml",
      "markdown", "markdown_inline", "toml", "vim", "query", "regex",
      "nasm", "glsl", "wgsl", "dart", "vue" },
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true,
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

  vim.keymap.set('n', '<F2>', ':NvimTreeFocus<CR>', { noremap = true, silent = true })

  local lspconfig = require('lspconfig')
  lspconfig.pyright.setup{}

local last_cbuff = nil

vim.api.nvim_create_user_command("C", function(opts)
  local cmd = table.concat(opts.fargs, " ")
  local start_time = vim.loop.hrtime()

  vim.cmd("botright split | resize 20 | terminal " .. cmd)

  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_get_current_buf()
  last_cbuff = term_buf  -- save for later

  -- move cursor to bottom of terminal buffer (shift+g)
  vim.api.nvim_buf_call(term_buf, function()
    vim.cmd("normal! G")
  end)

  -- auto-close on winleave
  vim.api.nvim_create_autocmd("winleave", {
    buffer = term_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
      end
    end,
  })

  -- print exit code and duration
  vim.api.nvim_create_autocmd("termclose", {
    buffer = term_buf,
    once = true,
    callback = function(args)
      local elapsed = (vim.loop.hrtime() - start_time) / 1e9
      local exit_code = args.data or 0

      vim.schedule(function()
        print(string.format("process finished in %.2f seconds", elapsed))
      end)
    end,
  })
end, { nargs = "+" })


-- Command to reopen last terminal buffer
vim.api.nvim_create_user_command("Cb", function()
  if last_cbuff and vim.api.nvim_buf_is_valid(last_cbuff) then
    vim.cmd("botright split | resize 20")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, last_cbuff)

    vim.api.nvim_create_autocmd("winleave", {
      buffer = last_cbuff,
      once = true,
      callback = function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end,
    })
  else
    print("No valid buffer from :C command.")
  end
end, {})

-- Quick tab switch
vim.keymap.set("n", "Z", ":tab split<CR>", { noremap = true })

-- Don't create a swap file
vim.o.swapfile = false

vim.cmd([[
  autocmd FileType dart,javascript,typescript,json,yaml,html,css,lua,graphql setlocal shiftwidth=2 tabstop=2 expandtab
]])

