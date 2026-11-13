-- ~/.config/nvim/init.lua   (Windows: %LOCALAPPDATA%\nvim\init.lua)
-- Single-file Neovim config. Transparent Gruvbox Dark Hard so the WezTerm blur shows through.
-- Needs Neovim 0.11+. Plugins install themselves on first launch.

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

----------------------------------------------------------------------
-- Options
----------------------------------------------------------------------
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.showmode = false
opt.laststatus = 3
opt.pumheight = 12
opt.inccommand = "split"
opt.confirm = true
opt.list = true
opt.listchars = { tab = "\u{bb} ", trail = "\u{b7}", nbsp = "\u{2423}" }
opt.fillchars = { eob = " " }

----------------------------------------------------------------------
-- Keymaps (leader = Space)
----------------------------------------------------------------------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv")
map("v", ">", ">gv")

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 180 })
  end,
})

----------------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------------
local sev = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = { prefix = "\u{25cf}", spacing = 2 },
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [sev.ERROR] = "\u{f057} ",
      [sev.WARN] = "\u{f071} ",
      [sev.INFO] = "\u{f05a} ",
      [sev.HINT] = "\u{f0eb} ",
    },
  },
})

----------------------------------------------------------------------
-- LSP keymaps (active when a language server attaches)
----------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local function m(keys, fn, desc, extra)
      vim.keymap.set("n", keys, fn, vim.tbl_extend("force", { buffer = ev.buf, desc = desc }, extra or {}))
    end
    m("gd", function() Snacks.picker.lsp_definitions() end, "Go to definition")
    m("gr", function() Snacks.picker.lsp_references() end, "References", { nowait = true })
    m("gI", function() Snacks.picker.lsp_implementations() end, "Implementations")
    m("K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover docs")
    m("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    m("<leader>ca", vim.lsp.buf.code_action, "Code action")
    m("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format file")
    m("<leader>ss", function() Snacks.picker.lsp_symbols() end, "Document symbols")
  end,
})

----------------------------------------------------------------------
-- lazy.nvim bootstrap
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local header = [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]]

require("lazy").setup({
  -- Colorscheme: Gruvbox Dark Hard, contrast tuned up, transparent
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- palette + highlight overrides rendered by `ox theme`
      local ok, ox = pcall(dofile, vim.fn.expand("~/.config/ox/current/nvim.lua"))
      if not ok then ox = { palette = {}, overrides = {} } end
      require("gruvbox").setup({
        contrast = "hard",
        transparent_mode = true,
        italic = { strings = false, emphasis = true, comments = true, operators = false, folds = true },
        palette_overrides = ox.palette,
        overrides = ox.overrides,
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- Snacks: dashboard, file picker, explorer, notifications, indent guides, smooth scroll
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = { header = header },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true, style = "compact" },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep text" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help pages" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
      { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notifications" },
      { "<C-/>", function() Snacks.terminal() end, desc = "Toggle terminal", mode = { "n", "t" } },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "\u{e0b6}" }, right_padding = 2 } },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { { "location", separator = { right = "\u{e0b4}" }, left_padding = 2 } },
      },
    },
  },

  -- Syntax highlighting (needs the tree-sitter CLI + a C compiler)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if ok and ts.install then
        ts.install({
          "bash", "c", "css", "go", "html", "javascript", "json", "lua", "markdown",
          "markdown_inline", "python", "rust", "sql", "toml", "tsx", "typescript",
          "vim", "vimdoc", "yaml",
        })
      end
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- LSP: Mason installs servers, Neovim 0.11 native LSP runs them
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
      end
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim", "Snacks" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "bashls", "jsonls" },
      })
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        menu = { border = "rounded" },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "\u{258e}" },
        change = { text = "\u{258e}" },
        delete = { text = "\u{f0da}" },
        topdelete = { text = "\u{f0da}" },
        changedelete = { text = "\u{258e}" },
        untracked = { text = "\u{258e}" },
      },
    },
  },

  -- Key hint popup (press Space and wait)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      win = { border = "rounded" },
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "symbols" },
      },
    },
  },

  -- Ctrl+h/j/k/l moves between Neovim splits AND tmux panes
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Pane left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Pane down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Pane up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Pane right" },
    },
  },

  -- Auto pairs, surround, better text objects
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.ai").setup()
    end,
  },
}, {
  install = { colorscheme = { "gruvbox" } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
