-- Neovim Configuration
-- Based on jdhao's comprehensive nvim-config
-- Personal configuration supporting Mac, Linux, and Windows

-- Check Neovim version compatibility
if vim.fn.has("nvim-0.8") == 0 then
  vim.api.nvim_err_writeln("This config requires Neovim >= 0.8")
  return
end

-- Load global variables and settings
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

-- Load plugins
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
})

-- Set colorscheme
vim.cmd("colorscheme kanagawa")

-- Enable filetype plugin and indent
vim.cmd("filetype plugin indent on")

print("Neovim configuration loaded successfully!")