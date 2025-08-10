-- Neovim Configuration
-- Personal configuration inspired by jdhao's nvim-config
-- Supports macOS, Linux, and Windows

-- Check Neovim version compatibility
if vim.fn.has("nvim-0.8") == 0 then
  vim.api.nvim_err_writeln("This config requires Neovim >= 0.8")
  return
end

-- Load core configuration modules
require("globals")
require("options")
require("mappings")
require("autocmds")

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins with lazy.nvim
require("lazy").setup("plugins", {
  ui = {
    border = "rounded",
  },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load colorschemes configuration
require("colorschemes")

-- Load custom autocommands
require("custom-autocmd")

-- Load diagnostic configuration
require("diagnostic-conf")

-- Enable filetype detection and plugins
vim.cmd("filetype plugin indent on")